import { onCall, HttpsError } from "firebase-functions/v2/https";
import { verifySubscription, writeEntitlement } from "./playBilling";

interface VerifyPurchaseRequest {
  purchaseToken?: string;
  productId?: string;
}

/**
 * Called by the client immediately after `in_app_purchase` reports a
 * successful purchase, so the UI can unlock Pro without waiting for RTDN
 * (which can lag by seconds to minutes). RTDN (onPlayRTDN) remains the
 * source of truth for renewals/cancellations that happen while the app
 * isn't open.
 */
export const verifyPurchase = onCall<VerifyPurchaseRequest>(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const { purchaseToken, productId } = request.data;
  if (!purchaseToken || !productId) {
    throw new HttpsError("invalid-argument", "purchaseToken and productId are required.");
  }

  const sub = await verifySubscription(productId, purchaseToken);
  if (sub.uid && sub.uid !== request.auth.uid) {
    throw new HttpsError("permission-denied", "Purchase does not belong to this account.");
  }

  await writeEntitlement(request.auth.uid, sub);
  return { isPro: sub.isActive };
});
