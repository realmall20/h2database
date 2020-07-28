/*
 * Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.mvstore.tx;

import java.util.BitSet;

import org.h2.mvstore.RootReference;

/**
 * Snapshot of the map root and committing transactions.
 * 当前 tree数的镜像数据
 *
 */
final class Snapshot<K,V> {

    /**
     * The root reference.
     * 根路径地址
     */
    final RootReference<K,V> root;

    /**
     * The committing transactions (see also TransactionStore.committingTransactions).
     * 正在提交中的事务
     */
    final BitSet committingTransactions;

    /**
     *
     * @param root  当前提交的数据
     * @param committingTransactions  正在提交的事务
     */
    Snapshot(RootReference<K,V> root, BitSet committingTransactions) {
        //根路径
        this.root = root;
        //提交的事务
        this.committingTransactions = committingTransactions;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + committingTransactions.hashCode();
        result = prime * result + root.hashCode();
        return result;
    }

    @SuppressWarnings("unchecked")
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Snapshot)) {
            return false;
        }
        Snapshot<K,V> other = (Snapshot<K,V>) obj;
        return committingTransactions == other.committingTransactions && root == other.root;
    }

}
