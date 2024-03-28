function Invoke-CIPPStandardPhishProtection {
    <#
    .FUNCTIONALITY
    Internal
    #>

    param($Tenant, $TenantId, $URL)
    

    try {
        $currentBody = (New-GraphGetRequest -Uri "https://graph.microsoft.com/beta/organization/$($TenantId.customerId)/branding/localizations/0/customCSS" -tenantid $tenant)
    } catch {
        Write-LogMessage -API 'Standards' -tenant $tenant -message "Could not get the branding for $($Tenant). This tenant might not have premium licenses available: $($_.Exception.Message)" -sev Error
    }
    $CSS = @"
.ext-sign-in-box {
    background-image: url($($URL)/api/PublicPhishingCheck?Tenantid=$TenantId);
}
"@
    try {
            if (!$currentBody) {
                $AddedHeaders = @{'Accept-Language' = 0 }
                $defaultBrandingBody = '{"usernameHintText":null,"signInPageText":null,"backgroundColor":null,"customPrivacyAndCookiesText":null,"customCannotAccessYourAccountText":null,"customForgotMyPasswordText":null,"customTermsOfUseText":null,"loginPageLayoutConfiguration":{"layoutTemplateType":"default","isFooterShown":true,"isHeaderShown":false},"loginPageTextVisibilitySettings":{"hideAccountResetCredentials":false,"hideTermsOfUse":true,"hidePrivacyAndCookies":true},"contentCustomization":{"conditionalAccess":[],"attributeCollection":[]}}'
                try {
                    New-GraphPostRequest -tenantid $tenant -Uri "https://graph.microsoft.com/beta/organization/$($TenantId.customerId)/branding/localizations/" -ContentType 'application/json' -asApp $true -Type POST -Body $defaultBrandingBody -AddedHeaders $AddedHeaders
                } catch { 
                
                }
            }
            if ($currentBody -like "*$CSS*") {
                Write-Host 'Logon Screen Phishing Protection system already active'
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Logon Screen Phishing Protection system already active' -sev Info
            } else {
                $currentBody = $currentBody + $CSS
                Write-Host 'Creating Logon Screen Phising Protection System'
                New-GraphPostRequest -tenantid $tenant -Uri "https://graph.microsoft.com/beta/organization/$($TenantId.customerId)/branding/localizations/0/customCSS" -ContentType 'text/css' -asApp $true -Type PUT -Body $currentBody

                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Enabled Logon Screen Phishing Protection system' -sev Info
            }
        } catch {
            Write-LogMessage -API 'Standards' -tenant $tenant -message "Could not set Logon Screen Phishing Protection System for $($Tenant): $($_.Exception.Message)" -sev Error
        }
        
        
    }

Invoke-CIPPStandardPhishProtection('MyTenant','MyTenantID','https://cipp.mycompany.com');
