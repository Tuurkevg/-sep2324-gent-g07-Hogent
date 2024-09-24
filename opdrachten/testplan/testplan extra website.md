# Testplan: Extra website

- Auteur(s) testplan: Matteo Alexander

**Opgelet**: de output kan verschillen in een echte opstelling, het gegeven "Verwacht resultaat" voor een test is slechts een placeholder voor een mogelijk geldige output. Het apparaat waar de test op wordt uitgevoerd, staat telkens tussen haakjes in de titel van elke test/stap.

1) Ga naar de juiste directory *(Hostmachine VM's)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07> cd .\opdrachten\Linux\Vagrant-VirtualeMachine\
```

2) Start de web, db, rp vm op *(Hostmachine VM's)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07\opdrachten\Linux\Vagrant-VirtualeMachine> vagrant up db web rp
```

3) Log in op de web vm *(Hostmachine VM's)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07\opdrachten\Linux\Vagrant-VirtualeMachine> vagrant ssh web
```

4) Bekijk nu de wordpress config file voor de extra website *(Webserver VM)*

```
[vagrant@extra conf.d]$ sudo cat /etc/httpd/conf.d/extra.conf
<VirtualHost *:80>
    ServerAdmin webmaster@extra.g07-blame.internal
    ServerName extra.g07-blame.internal
    ServerAlias www.extra.g07-blame.internal
    DocumentRoot /var/www/html/extra

    <Directory /var/www/html/extra/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/extra.g07-blame.internal_error.log
    CustomLog /var/log/httpd/extra.g07-blame.internal_access.log combined
</VirtualHost>
```

5) Probeer nu te surfen naar "extra.g07-blame.internal" je zou nu onze extra website moeten zien verschijnen *(Client-VM)*

![website](img/extrasite.png)