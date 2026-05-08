package com.hospital.auth.migration;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.index.Index;
import org.springframework.data.mongodb.core.index.IndexOperations;
import org.springframework.stereotype.Component;

/**
 * Idempotent index migration for the users collection.
 *
 * Why an explicit migration instead of @Indexed + auto-index-creation:
 *   - auto-index-creation rescans all @Document classes on every startup and
 *     blocks the collection while creating indexes — unsafe under production load.
 *   - ensureIndex() is a MongoDB no-op when called with an identical definition,
 *     so this runner is safe to execute on every startup or in rolling deploys.
 *
 * Indexes created here:
 *   1. users.username    — unique (non-sparse). All users have a username.
 *   2. users.phoneNumber — unique, sparse.  Sparse means documents where
 *      phoneNumber is null are excluded from the index, preserving backward
 *      compatibility with legacy accounts created before this field existed.
 */
@Slf4j
@Component
public class PhoneNumberIndexMigration implements ApplicationRunner {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Override
    public void run(ApplicationArguments args) {
        IndexOperations indexOps = mongoTemplate.indexOps("users");

        indexOps.ensureIndex(
                new Index()
                        .on("username", Sort.Direction.ASC)
                        .unique()
                        .named("idx_users_username_unique")
        );

        // sparse() — documents without a phoneNumber field are excluded from the
        // uniqueness constraint, so pre-existing rows are never rejected.
        indexOps.ensureIndex(
                new Index()
                        .on("phoneNumber", Sort.Direction.ASC)
                        .unique()
                        .sparse()
                        .named("idx_users_phoneNumber_sparse_unique")
        );

        log.info("Migration: ensured indexes on users.username and users.phoneNumber");
    }
}
