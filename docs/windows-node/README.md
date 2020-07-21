# How to add a Windows Node

## Add Windows node

Download 
* Latest VirtIO driver: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.185-2/virtio-win-0.1.185.iso
* Download Windows 2019 Server ISO:


```bash
./docs/windows-node/add-windows-node.yaml -e @cluster-demo2.yaml
```

lsof -i -n  | grep qemu-kvm
qemu-kvm   71454    qemu   25u  IPv4 592396      0t0  TCP 127.0.0.1:rfb (LISTEN)
qemu-kvm   71568    qemu   24u  IPv4 589479      0t0  TCP 127.0.0.1:5901 (LISTEN)
qemu-kvm   71677    qemu   24u  IPv4 595126      0t0  TCP 127.0.0.1:5902 (LISTEN)
qemu-kvm   71786    qemu   24u  IPv4 595275      0t0  TCP 127.0.0.1:5903 (LISTEN)
qemu-kvm   71898    qemu   22u  IPv4 585712      0t0  TCP 127.0.0.1:5904 (LISTEN)
qemu-kvm   72008    qemu   22u  IPv4 595455      0t0  TCP 127.0.0.1:5905 (LISTEN)
qemu-kvm   72116    qemu   22u  IPv4 586676      0t0  TCP 127.0.0.1:5906 (LISTEN)
qemu-kvm  111832    qemu   26u  IPv4 685146      0t0  TCP 127.0.0.1:5907 (LISTEN)

ssh -L 5907:127.0.0.1:5907 <hetzner>


=> start your VNC Client and install Windows

## Windows Installation

List of  Disk is empty, please install VirtIO driver:

![ ](select-virtIO.png "")

![Select VirtIO](select-virtIO.png "Select VirtIO")

![Select Windows Server Datacenter with Desktop](select-windows-datacenter-with-gui.png "Select Windows Server Datacenter with Desktop")

## Windows Configuration

### Install VirtIO

Important: Use latest upstream because of:

![VirtIO Error](rhel-virtio-error.png "VirtIO Error")

### Enable Remote Desktop (Optional)



### Enable Hyper-V

 * **1**
   ![HyperV Step 1](hyper-v-1.png "HyperV Step 1")
 * **10**
   ![HyperV Step 10](hyper-v-10.png "HyperV Step 10")
 * **11**
   ![HyperV Step 11](hyper-v-11.png "HyperV Step 11")
 * **12**
   ![HyperV Step 12](hyper-v-12.png "HyperV Step 12")
 * **13**
   ![HyperV Step 13](hyper-v-13.png "HyperV Step 13")
 * **14**
   ![HyperV Step 14](hyper-v-14.png "HyperV Step 14")
 * **2**
   ![HyperV Step 2](hyper-v-2.png "HyperV Step 2")
 * **3**
   ![HyperV Step 3](hyper-v-3.png "HyperV Step 3")
 * **4**
   ![HyperV Step 4](hyper-v-4.png "HyperV Step 4")
 * **5**
   ![HyperV Step 5](hyper-v-5.png "HyperV Step 5")
 * **6**
   ![HyperV Step 6](hyper-v-6.png "HyperV Step 6")
 * **7**
   ![HyperV Step 7](hyper-v-7.png "HyperV Step 7")
 * **8**
   ![HyperV Step 8](hyper-v-8.png "HyperV Step 8")
 * **9**
   ![HyperV Step 9](hyper-v-9.png "HyperV Step 9")

### Install Docker

Official Windows Documentation: [Get started: Prep Windows for containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=Windows-Server)

![Docker Setup](docker.png "Docker  Setup")

PowerShell
```
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Install-Package -Name docker -ProviderName DockerMsftProvider

Restart-Computer -Force

```

### Enable Remote Managment

```
winrm quickconfig
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```



## Join Windows to OCP Cluster


