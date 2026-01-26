using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

class Example
{
    void Good1()
    {
        // GOOD: Use default certificate validation (don't set the callback)
        var request = WebRequest.Create("https://example.com");
    }

    void Good2()
    {
        // GOOD: Implement proper certificate validation logic
        ServicePointManager.ServerCertificateValidationCallback += 
            (sender, certificate, chain, sslPolicyErrors) =>
            {
                if (sslPolicyErrors == SslPolicyErrors.None)
                {
                    return true;
                }
                
                // Log the error and reject the certificate
                Console.WriteLine("Certificate error: {0}", sslPolicyErrors);
                return false;
            };
    }

    void Good3()
    {
        // GOOD: Validate specific certificate properties (certificate pinning)
        var trustedThumbprints = new[] { "ABC123DEF456..." };
        
        ServicePointManager.ServerCertificateValidationCallback += 
            (sender, certificate, chain, sslPolicyErrors) =>
            {
                var cert = certificate as X509Certificate2;
                if (cert != null && Array.IndexOf(trustedThumbprints, cert.Thumbprint) >= 0)
                {
                    return true;
                }
                
                return sslPolicyErrors == SslPolicyErrors.None;
            };
    }
}
