/*
 * Copyright 2004-2020 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.expression.function;

import org.h2.engine.SessionLocal;
import org.h2.expression.Expression;
import org.h2.util.HasSQL;
import org.h2.value.ValueResultSet;

/**
 * This interface is used by the built-in functions,
 * as well as the user-defined functions.
 */
public interface FunctionCall extends HasSQL, NamedExpression {

    /**
     * Get the name of the function.
     *
     * @return the name
     */
    @Override
    String getName();

    /**
     * Get an empty result set with the column names set.
     *
     * @param session the session
     * @param nullArgs the argument list (some arguments may be null)
     * @return the empty result set
     */
    ValueResultSet getValueForColumnList(SessionLocal session, Expression[] nullArgs);

    /**
     * Get the data type.
     *
     * @return the data type
     */
    int getValueType();

    /**
     * Optimize the function if possible.
     *
     * @param session the session
     * @return the optimized expression
     */
    Expression optimize(SessionLocal session);

    /**
     * Get the function arguments.
     *
     * @return argument list
     */
    Expression[] getArgs();

    /**
     * Whether the function always returns the same result for the same
     * parameters.
     *
     * @return true if it does
     */
    boolean isDeterministic();

}
