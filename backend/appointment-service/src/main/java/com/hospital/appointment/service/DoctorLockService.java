package com.hospital.appointment.service;

import org.springframework.stereotype.Service;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

/**
 * In-memory fallback distributed lock mechanism scoped to doctorId protecting 
 * non-transactional offset overlap bounds structurally safely. 
 */
@Service
public class DoctorLockService {

    private final ConcurrentHashMap<String, ReentrantLock> locks = new ConcurrentHashMap<>();

    private ReentrantLock getLock(String doctorId) {
        return locks.computeIfAbsent(doctorId, k -> new ReentrantLock());
    }

    public boolean tryLock(String doctorId, long timeout, TimeUnit unit) throws InterruptedException {
        return getLock(doctorId).tryLock(timeout, unit);
    }

    public void unlock(String doctorId) {
        ReentrantLock lock = locks.get(doctorId);
        if (lock != null && lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
