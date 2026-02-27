package com.backend.aura.modules.user.service;

import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class EmailOtpStore {

    private static final long OTP_TTL_MS = 10 * 60 * 1000;

    private final Map<String, OtpEntry> store = new ConcurrentHashMap<>();

    public String generateAndStore(String email) {
        String otp = String.format("%06d", new Random().nextInt(1000000));
        store.put(email.toLowerCase(), new OtpEntry(otp, Instant.now().toEpochMilli()));
        return otp;
    }

    public boolean verify(String email, String otp) {
        OtpEntry entry = store.get(email.toLowerCase());
        if (entry == null)
            return false;
        if (Instant.now().toEpochMilli() - entry.createdAt > OTP_TTL_MS) {
            store.remove(email.toLowerCase());
            return false;
        }
        boolean valid = entry.otp.equals(otp);
        if (valid)
            store.remove(email.toLowerCase());
        return valid;
    }

    private static class OtpEntry {
        final String otp;
        final long createdAt;

        OtpEntry(String otp, long createdAt) {
            this.otp = otp;
            this.createdAt = createdAt;
        }
    }
}
