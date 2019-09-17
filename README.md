# DOCKEREVIL - No SSH-BS!

So... In the original script we use the Docker API to write our SSH public key to the victim host, allowing us to access it as root. But I noticed that the script will fail if the SSH directory structure isn't created on the host machine. That can easily be treated on the original script, checking for the file structure and creating if necessary before we inject our SSH key, but what if the SSH daemon isn't even running on the host machine? D:

For this reason I'm creating this new repository, which might be absorbed by the original DOCKEREVIL repo in the future.

In this version of the DOCKEREVIL script (No SSH Bullshit/No SSH - Bind Shell) instead of injecting our publich SSH key on the victim host, we'll create a bind shell. The BS will be created as an hidden file, which will be called by cron every minute. You can easily modify the script to change the payload and the parameters that will be passed to cron.

Yes, I'm well aware that this bindshell would be incredibly easy to detect. (:

I'm not responsible for any bad/ilegal use of the code. This is for study and ethical work only.

![alt text](https://github.com/CodeStudent1995/dckrEvil-NoSSH-BS/blob/master/DOCKEREVIL.png)
