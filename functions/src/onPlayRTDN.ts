import { onMessagePublished } from "firebase-functions/v2/pubsub";
import { logger } from "firebase-functions/v2";
import { verifySubscription, writeEntitlement } from "./playBilling";

/** https://developer.android.com/google/play/billing/rtdn-reference#sub */
interface SubscriptionNotification {
  version: string;
  notificationType: number;
  purchaseToken: string;
  subscriptionId: string;
}

interface DeveloperNotification {
  packageName: string;
  eventTimeMillis: string;
  subscriptionNotification?: SubscriptionNotification;
}

/**
 * Handles Real-time Developer Notifications from Play — renewals,
 * cancellations, grace period, expiry, refunds, etc. — so `users/{uid}.isPro`
 * stays correct even when the app never opens again after a subscription
 * lapses. Topic name must match the one linked under Play Console ->
 * Monetization setup -> Real-time developer notifications.
 */
export const onPlayRTDN = onMessagePublished("play-subscription-events", async (event) => {
  const notification = event.data.message.json as DeveloperNotification | undefined;
  const subNotification = notification?.subscriptionNotification;
  if (!subNotification) {
    logger.info("Ignoring RTDN without a subscriptionNotification payload", notification);
    return;
  }

  const sub = await verifySubscription(subNotification.subscriptionId, subNotification.purchaseToken);
  if (!sub.uid) {
    logger.warn("RTDN purchase has no obfuscatedExternalAccountId, cannot map to a uid", subNotification);
    return;
  }

  await writeEntitlement(sub.uid, sub);
});
