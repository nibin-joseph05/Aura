package com.backend.aura.modules.auth.firebase.service;

import com.backend.aura.modules.auth.firebase.context.AuthenticatedUserContext;
import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.model.enums.SignupMethod;
import com.backend.aura.modules.user.service.UserService;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Map;

@Service
public class FirebaseAuthService {

    private final UserService userService;

    public FirebaseAuthService(UserService userService) {
        this.userService = userService;
    }

    public AuthenticatedUserContext verifyTokenAndSyncUser(String idToken) {
        try {
            FirebaseToken decodedToken =
                    FirebaseAuth.getInstance().verifyIdToken(idToken);

            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();

            String phone = (String) decodedToken.getClaims()
                    .get("phone_number");

            Map<String, Object> firebaseClaims =
                    (Map<String, Object>) decodedToken.getClaims()
                            .get("firebase");

            String provider = firebaseClaims != null
                    ? (String) firebaseClaims.get("sign_in_provider")
                    : null;

            SignupMethod signupMethod = mapSignupMethod(provider);

            User user = new User();
            user.setUid(uid);
            user.setEmail(email);
            user.setPhone(phone);
            user.setSignupMethod(signupMethod);
            user.setEmailVerified(email != null);
            user.setPhoneVerified(phone != null);
            user.setLastLoginAt(new Date());

            setProviderLinks(user, provider);

            userService.createOrUpdateUser(user);

            return new AuthenticatedUserContext(uid, email, phone, provider);

        } catch (Exception e) {
            throw new RuntimeException("Invalid Firebase token", e);
        }
    }

    private void setProviderLinks(User user, String provider) {
        if (provider == null) {
            user.setEmailPasswordLinked(true);
            return;
        }

        switch (provider) {
            case "google.com":
                user.setGoogleLinked(true);
                break;
            case "phone":
                user.setPhoneLinked(true);
                break;
            default:
                user.setEmailPasswordLinked(true);
                break;
        }
    }

    private SignupMethod mapSignupMethod(String provider) {
        if (provider == null) return SignupMethod.EMAIL;

        return switch (provider) {
            case "google.com" -> SignupMethod.GOOGLE;
            case "phone" -> SignupMethod.PHONE;
            default -> SignupMethod.EMAIL;
        };
    }
}