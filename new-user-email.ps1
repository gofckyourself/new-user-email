#задаем параметры подключения к Exchange
$SMTPServer = "ip_or_dns"
$SMTPPort = 587
$Username = "from_email"
#лучше обеспечить хранение пароля в более безопасном виде, но пока так
$Password = 'secure_password'
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, ($Password | ConvertTo-SecureString -AsPlainText -Force)
#переменная для получения даты
$StartTime = (Get-Date).AddDays(-1).AddHours(9)  # Время начала проверки (например, 9:00 вчера)
$EndTime = (Get-Date).AddHours(9)               # Время конца проверки (9:00 сегодня)

#определим OU
$OU = "OU=test,DC=example,DC=com"
$users = Get-ADUser -Filter {
    whenCreated -ge $StartTime -and whenCreated -lt $EndTime
} -Properties whenCreated,mail -SearchBase $OU

foreach ($User in $Users) {
#зададим переменные для имени и почты, т.к. прямое указание через $user. не работает внутри
$FirstName = $User.GivenName
$email = $User.mail

#формируем тело письма с использованием переменных (вставить сюда html код)
$Body = @"

"@

#параметры сообщения
$MessageParameters = @{
    To = "$email"
    Subject = "Добро пожаловать, $FirstName!"
    Body = $Body
    SmtpServer = $SMTPServer
    Port = $SMTPPort
    From = $Username
    UseSSL = $false
    Credential = $Cred
    BodyAsHtml = $true
    Encoding = [System.Text.Encoding]::UTF8
}

#отправка письма
Send-MailMessage @MessageParameters
}
