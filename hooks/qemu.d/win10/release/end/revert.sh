# Debug
set -x

# Load Variables
source "/etc/libvirt/hooks/kvm.conf"

# unload vfio-pci
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Rebind GPU
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO

# rebind VTconsoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Bind EFI-framebuffer
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# mem reset?
rtcwake -m mem -s 5

# load AMD
modprobe amdgpu
# modprobe snd_hda_intel

# Restart Display Service
systemctl start sddm.service
