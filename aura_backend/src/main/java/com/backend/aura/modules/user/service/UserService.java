package com.backend.aura.modules.user.service;

import com.backend.aura.modules.user.model.User;
import com.backend.aura.modules.user.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User saveUser(User user) {
        return userRepository.save(user);
    }

    public User getUser(String uid) {
        return userRepository.findById(uid).orElse(null);
    }
}
