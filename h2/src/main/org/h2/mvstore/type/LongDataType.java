/*
 * Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.mvstore.type;

import org.h2.mvstore.DataUtils;
import org.h2.mvstore.WriteBuffer;

import java.nio.ByteBuffer;

/**
 * Class LongDataType.
 * <UL>
 * <LI> 8/21/17 6:52 PM initial creation
 * </UL>
 *
 * @author <a href='mailto:andrei.tokar@gmail.com'>Andrei Tokar</a>
 */
public class LongDataType extends BasicDataType<Long> {
    public static final LongDataType INSTANCE = new LongDataType();
    public static final Long[] EMPTY_LONG_ARR = new Long[0];

    public LongDataType() {
    }

    @Override
    public int getMemory(Long obj) {
        return 8;
    }

    @Override
    public void write(WriteBuffer buff, Long data) {
        buff.putVarLong(data);
    }

    @Override
    public Long read(ByteBuffer buff) {
        return DataUtils.readVarLong(buff);
    }

    @Override
    public Long[] createStorage(int size) {
        return size == 0 ? EMPTY_LONG_ARR : new Long[size];
    }

    @Override
    public int compare(Long one, Long two) {
        return Long.compare(one, two);
    }

    @Override
    public int binarySearch(Long keyObj, Object storageObj, int size, int initialGuess) {
        long key = keyObj;
        Long[] storage = cast(storageObj);
        int low = 0;
        //最大值
        int high = size - 1;
        // the cached index minus one, so that
        // for the first time (when cachedCompare is 0),
        // the default value is used
        int x = initialGuess - 1;
        if (x < 0 || x > high) {
            x = high >>> 1;
        }
        return binarySearch(key, storage, low, high, x);
    }

    /**
     * 中间查询
     * 1，2，3，4，5 查 7
     * 最大的可能是 5+5 >>>1 =0 return -1  意味着找不到。
     * <p>
     * 1,2,3,4,6 查 5呢
     * 1: 5 > 1 low=0 high=4 ,x=2
     * 2: 5>3  low=3 high=4 ,x=3
     * 3: 5>4 low=4 high=4 , x=0 还是找不到，还是返回-1 。
     * @param key
     * @param storage
     * @param low
     * @param high
     * @param x
     * @return
     */
    private static int binarySearch(long key, Long[] storage, int low, int high, int x) {
        while (low <= high) {
            long midVal = storage[x];
            if (key > midVal) {
                low = x + 1;
            } else if (key < midVal) {
                high = x - 1;
            } else {
                return x;//这种情况下可以说刚好找到
            }
            x = (low + high) >>> 1;
        }
        // 这种情况下算怎么回事 ？？？
        return -(low + 1);
    }
}
