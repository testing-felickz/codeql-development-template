using System.Net;
using System.Net.Security;

class Example
{
    void Bad()
    {
        // BAD: Disables SSL certificate validation globally for all HTTPS requests
        ServicePointManager.ServerCertificateValidationCallback += 
            (sender, certificate, chain, sslPolicyErrors) => true;
    }
}
