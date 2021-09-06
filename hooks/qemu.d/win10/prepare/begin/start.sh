#debugging
set -x

# load variables we defined
source "/etc/libvirt/hooks/kvm.conf"

# stop display manager
systemctl stop sddm.service

# getting pulse and releasing them
# pulse_pid=$(pgrep -u indianjones pulseaudio)
# pipewire_pid=$(pgrep -u indianjones pipewire-media)
# kill $pulse_pid
# kill $pipewire_pid

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid race condition
sleep 5

# Unload AMD
modprobe -r amdgpu
# modprobe -r snd_hda_intel

# unbind gpu
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

rtcwake -m mem -s 5

# load vfio
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
