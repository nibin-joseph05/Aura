package com.backend.aura.modules.notification.service;

import com.backend.aura.core.logging.AuraLogger;
import com.backend.aura.modules.notification.model.Notification;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.MulticastMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PushNotificationService {

    private final AuraLogger auraLogger;

    public boolean sendToUser(String fcmToken, String title, String body, String deepLink) {
        try {
            Message message = Message.builder()
                    .setToken(fcmToken)
                    .putData("title", title)
                    .putData("body", body)
                    .putData("deepLink", deepLink != null ? deepLink : "")
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            auraLogger.pushSent(fcmToken.substring(0, 10) + "...", "user");
            return response != null;
        } catch (Exception e) {
            auraLogger.pushFailed(fcmToken.substring(0, 10) + "...", e.getMessage());
            return false;
        }
    }

    public int sendToMultiple(List<String> fcmTokens, String title, String body, String deepLink) {
        if (fcmTokens == null || fcmTokens.isEmpty()) {
            return 0;
        }

        try {
            MulticastMessage message = MulticastMessage.builder()
                    .addAllTokens(fcmTokens)
                    .putData("title", title)
                    .putData("body", body)
                    .putData("deepLink", deepLink != null ? deepLink : "")
                    .build();

            var response = FirebaseMessaging.getInstance().sendEachForMulticast(message);
            auraLogger.pushSent("multicast", String.valueOf(response.getSuccessCount()) + " success");
            return response.getSuccessCount();
        } catch (Exception e) {
            auraLogger.pushFailed("multicast", e.getMessage());
            return 0;
        }
    }

    public boolean sendToTopic(String topic, String title, String body, String deepLink) {
        try {
            Message message = Message.builder()
                    .setTopic(topic)
                    .putData("title", title)
                    .putData("body", body)
                    .putData("deepLink", deepLink != null ? deepLink : "")
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            auraLogger.pushSent("topic", topic);
            return response != null;
        } catch (Exception e) {
            auraLogger.pushFailed("topic:" + topic, e.getMessage());
            return false;
        }
    }

    public void sendBroadcast(Notification notification) {
        sendToTopic("all_users", notification.getTitle(), notification.getBody(), notification.getDeepLink());
    }
}
