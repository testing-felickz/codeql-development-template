/**
 * Provides classes and predicates for detecting globally disabled SSL certificate validation.
 */

import csharp

/**
 * A property access to `ServicePointManager.ServerCertificateValidationCallback`.
 */
class ServerCertificateValidationCallbackAccess extends PropertyAccess {
  ServerCertificateValidationCallbackAccess() {
    this.getTarget().getName() = "ServerCertificateValidationCallback" and
    this.getTarget().getDeclaringType().hasFullyQualifiedName("System.Net", "ServicePointManager")
  }
}

/**
 * An assignment or compound assignment to `ServicePointManager.ServerCertificateValidationCallback`.
 */
class ServerCertificateValidationCallbackAssignment extends AssignExpr {
  ServerCertificateValidationCallbackAssignment() {
    this.getLValue() instanceof ServerCertificateValidationCallbackAccess
  }

  Expr getRightHandSide() { result = this.getRValue() }
}

/**
 * A compound assignment (+=) to `ServicePointManager.ServerCertificateValidationCallback`.
 */
class ServerCertificateValidationCallbackAddition extends AssignAddExpr {
  ServerCertificateValidationCallbackAddition() {
    this.getLValue() instanceof ServerCertificateValidationCallbackAccess
  }

  Expr getRightHandSide() { result = this.getRValue() }
}

/**
 * Holds if the method always returns true without any conditional logic.
 */
predicate methodAlwaysReturnsTrue(Method m) {
  // Method with expression body: => true
  m.getExpressionBody() instanceof BoolLiteral and
  m.getExpressionBody().(BoolLiteral).getValue() = "true"
  or
  // Method with single return statement: return true;
  exists(ReturnStmt ret |
    m.getStatementBody().(BlockStmt).getNumberOfStmts() = 1 and
    ret = m.getStatementBody().(BlockStmt).getStmt(0) and
    ret.getExpr() instanceof BoolLiteral and
    ret.getExpr().(BoolLiteral).getValue() = "true"
  )
}

/**
 * An expression that always returns true.
 */
predicate alwaysReturnsTrue(Expr e) {
  // Simple lambda: (args) => true
  exists(LambdaExpr lambda |
    e = lambda and
    lambda.getExpressionBody() instanceof BoolLiteral and
    lambda.getExpressionBody().(BoolLiteral).getValue() = "true"
  )
  or
  // Lambda with block body containing only "return true;"
  exists(LambdaExpr lambda, ReturnStmt ret |
    e = lambda and
    lambda.getStatementBody().(BlockStmt).getNumberOfStmts() = 1 and
    ret = lambda.getStatementBody().(BlockStmt).getStmt(0) and
    ret.getExpr() instanceof BoolLiteral and
    ret.getExpr().(BoolLiteral).getValue() = "true"
  )
  or
  // Method reference (as callable access) that always returns true
  exists(Method m |
    e.(CallableAccess).getTarget() = m and
    methodAlwaysReturnsTrue(m)
  )
  or
  // Method access (member access) that references a method always returning true
  exists(Method m |
    e.(MemberAccess).getTarget() = m and
    methodAlwaysReturnsTrue(m)
  )
  or
  // Delegate creation (implicit or explicit) from a method that always returns true
  exists(Method m |
    e.(DelegateCreation).getArgument() = m.getAnAccess() and
    methodAlwaysReturnsTrue(m)
  )
}

/**
 * An assignment or addition to ServerCertificateValidationCallback that always returns true,
 * thereby disabling SSL certificate validation globally.
 */
class GlobalSslDisable extends Expr {
  GlobalSslDisable() {
    this instanceof ServerCertificateValidationCallbackAssignment and
    alwaysReturnsTrue(this.(ServerCertificateValidationCallbackAssignment).getRightHandSide())
    or
    this instanceof ServerCertificateValidationCallbackAddition and
    alwaysReturnsTrue(this.(ServerCertificateValidationCallbackAddition).getRightHandSide())
  }

  Expr getCallback() {
    result = this.(ServerCertificateValidationCallbackAssignment).getRightHandSide()
    or
    result = this.(ServerCertificateValidationCallbackAddition).getRightHandSide()
  }
}
