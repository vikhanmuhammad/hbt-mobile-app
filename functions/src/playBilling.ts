import { google } from "googleapis";
import { getFirestore, FieldValue, type Firestore } from "firebase-admin/firestore";

/** Must match `applicationId` in android/app/build.gradle.kts. */
export const PACKAGE_NAME = "com.habtrack.habittracker";

export interface VerifiedSubscription {
  /** Firebase uid the purchase belongs to — set client-side as the Play
   * Billing `obfuscatedAccountId` when the purchase was made (see
   * PurchaseService.buy). Null if Play never got it (shouldn't happen for
   * purchases made through this app, but RTDN can't be trusted blindly). */
  uid: string | null;
  isActive: boolean;
  expiryTimeMillis: number | null;
  willRenew: boolean;
  productId: string;
}

async function androidPublisher() {
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  return google.androidpublisher({ version: "v3", auth });
}

/**
 * Re-verifies a subscription purchase directly against the Play Developer
 * API — never trust `purchaseToken`/`productId` reported by the client (or
 * even RTDN) without this round-trip, since both can be forged.
 */
export async function verifySubscription(
  productId: string,
  purchaseToken: string,
): Promise<VerifiedSubscription> {
  const publisher = await androidPublisher();
  const res = await publisher.purchases.subscriptionsv2.get({
    packageName: PACKAGE_NAME,
    token: purchaseToken,
  });
  const data = res.data;

  const uid = data.externalAccountIdentifiers?.obfuscatedExternalAccountId ?? null;
  const isActive =
    data.subscriptionState === "SUBSCRIPTION_STATE_ACTIVE" ||
    data.subscriptionState === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD";
  const lineItem = data.lineItems?.[0];
  const expiryTimeMillis = lineItem?.expiryTime
    ? new Date(lineItem.expiryTime).getTime()
    : null;
  const willRenew = Boolean(lineItem?.autoRenewingPlan?.autoRenewEnabled);

  return { uid, isActive, expiryTimeMillis, willRenew, productId };
}

/** The only place `users/{uid}` Pro fields get written — Firestore rules
 * block client writes, so this Admin SDK path is the sole source of truth. */
export async function writeEntitlement(
  uid: string,
  sub: VerifiedSubscription,
  db: Firestore = getFirestore(),
): Promise<void> {
  await db.collection("users").doc(uid).set(
    {
      isPro: sub.isActive,
      proProductId: sub.productId,
      proExpiryTimeMillis: sub.expiryTimeMillis,
      proWillRenew: sub.willRenew,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}
