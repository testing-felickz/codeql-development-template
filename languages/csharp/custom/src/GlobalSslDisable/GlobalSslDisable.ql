/**
 * @name Global SSL certificate validation disabled
 * @description Setting ServicePointManager.ServerCertificateValidationCallback to always return true
 *              disables SSL certificate validation globally, making the application vulnerable to
 *              man-in-the-middle attacks.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision high
 * @id csharp/web/insecure-ssl-validation
 * @tags security
 *       external/cwe/cwe-295
 */

import csharp
import GlobalSslDisable

from GlobalSslDisable disable
select disable,
  "Globally disabling SSL certificate validation makes the application vulnerable to man-in-the-middle attacks."
