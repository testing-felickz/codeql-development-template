using System;

// Mock types for testing purposes (since System.Net types are not available in test environment)
namespace System.Net
{
    public static class ServicePointManager
    {
        public static RemoteCertificateValidationCallback ServerCertificateValidationCallback { get; set; }
    }
    
    public delegate bool RemoteCertificateValidationCallback(object sender, object certificate, object chain, object sslPolicyErrors);
}

namespace GlobalSslDisableTests
{
    public class GlobalSslDisableTest
    {
        // NON_COMPLIANT: Lambda that always returns true - disables all SSL validation
        public void DisableAllSslValidationWithLambda()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
        }

        // NON_COMPLIANT: Lambda with explicit return true - disables all SSL validation
        public void DisableAllSslValidationWithExplicitReturn()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => 
            { 
                return true; 
            };
        }

        // NON_COMPLIANT: Direct assignment to always return true
        public void DisableAllSslValidationWithAssignment()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) => true;
        }

        // NON_COMPLIANT: Delegate method that always returns true
        public void DisableAllSslValidationWithDelegateMethod()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback += AlwaysAcceptCertificate;
        }

        private static bool AlwaysAcceptCertificate(object sender, object certificate, object chain, object sslPolicyErrors)
        {
            return true;
        }

        // NON_COMPLIANT: Another delegate that always returns true
        public void DisableAllSslValidationWithAnotherDelegate()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = AcceptAllCerts;
        }

        private static bool AcceptAllCerts(object sender, object cert, object chain, object errors)
        {
            return true;
        }

        // NON_COMPLIANT: Expression-bodied method that returns true
        private static bool AlwaysTrueExpressionBody(object sender, object certificate, object chain, object sslPolicyErrors) => true;

        public void DisableWithExpressionBodyDelegate()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = AlwaysTrueExpressionBody;
        }

        // COMPLIANT: Lambda with conditional logic that actually validates certificates
        public void ValidateCertificateWithCondition()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) =>
            {
                var x = 5;
                if (x > 0)
                {
                    return true;
                }
                return false;
            };
        }

        // COMPLIANT: Null assignment (resetting the callback)
        public void ResetCertificateValidation()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = null;
        }

        // COMPLIANT: Delegate method with actual validation logic
        public void DelegateWithValidation()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback += ValidateCertificate;
        }

        private static bool ValidateCertificate(object sender, object certificate, object chain, object sslPolicyErrors)
        {
            var y = 10;
            if (y > 5)
            {
                return true;
            }
            return false;
        }

        // COMPLIANT: Lambda that returns false (rejects all - not a security issue)
        public void RejectAllCertificates()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = (sender, certificate, chain, sslPolicyErrors) => false;
        }

        // COMPLIANT: Lambda with multiple statements but conditional return
        public void ConditionalValidation()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = (sender, cert, chain, errors) =>
            {
                var test = 42;
                return test > 0;
            };
        }
    }
}
