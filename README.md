# single-gpu-vfio-amd

Made by [bsarabeswaran](https://github.com/bsarabeswaran)

## Introduction and Sources

This is a light tutorial (with the files I used) for Single-GPU VFIO with Windows 10 on Arch Linux with both an AMD graphics card and an AMD Ryzen processor. A lot of the groundwork for what I figured out here was based on [this repo](https://github.com/cosminmocan/vfio-single-amdgpu-passthrough)(by cosminmocan) and [this repo](https://gitlab.com/Karuri/vfio)(by Maagu Karuri), so I thank them very much.

This will be done assuming that you know the basics of how to get started with VFIO (including setting up virt-manager with a Windows 10 install before this and other services), but I will go over some things, like how to check your IOMMU groupings.

## Check IOMMU groupings

You can use *iommuGroupings.sh* (Thanks [Maagu Karuri](https://gitlab.com/Karuri/vfio)) to display your IOMMU devices and the groups that they are in. You need to make sure that your graphics card (and most likely its sound component) are in an IOMMU group alone. If there are any other devices, then you must do ACS patching, which I won't get into here. Note that you may see a list of bridges, like dummy or host bridges. These can be ignored, and don't really play into what we are doing at all. I would copy down the graphics and sound addresses, like I did in *amdPassthru*, since we will be using them later.

## Libvirt Hooks
First, you need to set up libvirt hooks. This is found in [this repo](https://gitlab.com/Karuri/vfio). Once you do that, set up a file structure with the parent folder as seen in win10. Once you have all these folders set up, we also need to get a list of our addresses for *kvm.conf* (in the same location in the hooks folder). Go ahead and name our variables **VIRSH_GPU_VIDEO** and **VIRSH_GPU_AUDIO** and give them your corresponding addresses like I did in my scripts. Now, we can move into making our *start.sh* and *stop.sh* scripts in their corresponding locations. For the most part, you can keep them the way I did. It should work fine. However, make sure when you disable the display manager (*systemctl disable sddm.service*, in my case), you are killing the right service for your display manager, and that you are also disabling all the vtconsoles you have (and none extra). The reason we don't have anything else address specific really is because we already typed our own addresses into the *kvm.conf* file, which we are linking here. **NOTE:** I was only able to get this to work with *rtcwake -m mem -s 5*, but your mileage might vary. 

## Connecting to virt-manager
Note that the name of your virt-manager vm must be the same as the first subfolder in *qemu.d* (in my case, **win10**). I have given my virt-manager win10.xml file, which shows the devices I have added and what I have removed. Most notably, I added the two pcie devices of my graphics card (audio and video), as well as USB-passthru for my keyboard, headphones, and mouse. After you have added these and set up your cpu topology, networking, and virtual storage, you should be able to start the vm with your gpu detached from windows.

## However..
There are some drawbacks:

1. This only worked through kernel release 5.11.16, and I have been trying (but unable) to get it to work again.
2. Even when this did work, it took roughly 3 failed attempts at starting the vm to successfully get it started again.
3. The dreaded AMD reset bug doesn't allow for the GPU to rebind with the linux install, so the stop script, as of now, doesn't work. I have heard of people getting it to work with vendor-reset, but I had no such luck.

With all these issues, this isn't the best choice for a daily driver setup, but it is a pretty cool project to try out.

## Thanks:
- [Maagu Karuri](https://gitlab.com/Karuri/vfio)
- [cosminmocan](https://github.com/cosminmocan/vfio-single-amdgpu-passthrough)
- [risingprismtv](https://www.youtube.com/watch?v=eTX10QlFJ6c)
