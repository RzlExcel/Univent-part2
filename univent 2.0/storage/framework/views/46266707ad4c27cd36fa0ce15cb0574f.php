<?php $__env->startSection('title', 'Edit Profile - Univent'); ?>

<?php $__env->startSection('content'); ?>
    <div class="min-h-screen bg-slate-50/50 pt-28 pb-20 px-4 relative overflow-hidden">
        
        <div class="absolute -top-24 -left-24 w-96 h-96 bg-red-100 rounded-full blur-3xl opacity-50 -z-10"></div>

        <div class="max-w-4xl mx-auto">
            
            <form action="<?php echo e(route('profile.update')); ?>" method="POST" enctype="multipart/form-data">
                <?php echo csrf_field(); ?>
                <?php echo method_field('PUT'); ?>

                <div
                    class="bg-white rounded-[2.5rem] border border-slate-100 shadow-xl shadow-slate-200/50 overflow-hidden flex flex-col md:flex-row">

                    
                    <div
                        class="md:w-1/3 p-8 md:p-12 border-b md:border-b-0 md:border-r border-slate-50 flex flex-col items-center text-center">

                        
                        <div class="relative mb-8">
                            <div
                                class="absolute inset-0 bg-gradient-to-tr from-red-500 to-pink-500 rounded-full blur-2xl opacity-30 scale-110">
                            </div>

                            <div class="relative w-44 h-44 rounded-full p-1 bg-white shadow-sm">
                                
                                <img id="avatar-preview"
                                    src="<?php echo e($user->avatar ? (strlen($user->avatar) > 200 ? 'data:image/jpeg;base64,' . $user->avatar : asset('storage/' . $user->avatar)) : asset('images/default-avatar.svg')); ?>"
                                    class="w-full h-full rounded-full object-cover border-4 border-white shadow-inner"
                                    data-default="<?php echo e(asset('images/default-avatar.svg')); ?>">
                            </div>
                        </div>

                        <h3 class="text-xl font-black text-slate-900 mb-1 italic"><?php echo e($user->name); ?></h3>

                        
                        <div class="flex flex-col items-center gap-2">
                            <label for="avatar-upload-input"
                                class="text-[10px] font-black text-slate-400 uppercase tracking-widest cursor-pointer hover:text-red-500 transition-colors">
                                Update Photo
                            </label>
                            
                            <input type="file" id="avatar-upload-input" name="avatar_file" class="hidden"
                                accept="image/png, image/jpeg, image/jpg">

                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($user->avatar): ?>
                                <button type="button" id="btn-remove-photo"
                                    class="text-[9px] font-bold text-red-400 hover:text-red-600 uppercase tracking-tighter transition-colors">
                                    Remove Photo
                                </button>
                                <input type="hidden" name="remove_avatar" id="remove-avatar-input" value="0">
                            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                        </div>
                    </div>

                    
                    <div class="md:w-2/3 p-8 md:p-12 space-y-10">
                        <div>
                            <h2 class="text-2xl font-black text-slate-900 mb-2 italic tracking-tight uppercase">Edit
                                Personal Information</h2>
                            <p class="text-sm font-medium text-slate-500">Sesuaikan profilmu agar orang lain lebih mudah
                                mengenalimu.</p>
                        </div>

                        <div class="space-y-6">
                            
                            <div class="space-y-2">
                                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Full
                                    Name</label>
                                <div class="relative group">
                                    <div
                                        class="absolute inset-y-0 left-0 pl-5 flex items-center pointer-events-none text-slate-400 group-focus-within:text-red-500 transition-colors">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-s-user'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <input type="text" name="name" value="<?php echo e(old('name', $user->name)); ?>" required
                                        class="w-full pl-14 pr-6 py-4 bg-slate-50/50 border border-slate-100 rounded-[1.25rem] text-sm font-bold text-slate-700 focus:bg-white focus:ring-4 focus:ring-red-500/5 focus:border-red-200 outline-none transition-all">
                                </div>
                            </div>

                            
                            <div class="space-y-2">
                                <label
                                    class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Birthday</label>
                                <div class="relative group">
                                    <div
                                        class="absolute inset-y-0 left-0 pl-5 flex items-center pointer-events-none text-slate-400 group-focus-within:text-pink-500 transition-colors">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-s-cake'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <input type="date" name="birthday"
                                        value="<?php echo e(old('birthday', $user->profile?->birthday ? \Carbon\Carbon::parse($user->profile->birthday)->format('Y-m-d') : '')); ?>"
                                        class="w-full pl-14 pr-6 py-4 bg-slate-50/50 border border-slate-100 rounded-[1.25rem] text-sm font-bold text-slate-700 focus:bg-white focus:ring-4 focus:ring-pink-500/5 focus:border-pink-200 outline-none transition-all">
                                </div>
                            </div>

                            
                            <div class="space-y-2">
                                <label class="text-[10px] font-black uppercase tracking-widest text-slate-400 ml-1">Phone
                                    Number</label>
                                <div class="relative group">
                                    <div
                                        class="absolute inset-y-0 left-0 pl-5 flex items-center pointer-events-none text-slate-400 group-focus-within:text-slate-900 transition-colors">
                                        <?php if (isset($component)) { $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c = $component; } ?>
<?php if (isset($attributes)) { $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c = $attributes; } ?>
<?php $component = BladeUI\Icons\Components\Svg::resolve([] + (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag ? $attributes->all() : [])); ?>
<?php $component->withName('heroicon-s-phone'); ?>
<?php if ($component->shouldRender()): ?>
<?php $__env->startComponent($component->resolveView(), $component->data()); ?>
<?php if (isset($attributes) && $attributes instanceof Illuminate\View\ComponentAttributeBag): ?>
<?php $attributes = $attributes->except(\BladeUI\Icons\Components\Svg::ignoredParameterNames()); ?>
<?php endif; ?>
<?php $component->withAttributes(['class' => 'w-5 h-5']); ?>
<?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::processComponentKey($component); ?>

<?php echo $__env->renderComponent(); ?>
<?php endif; ?>
<?php if (isset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $attributes = $__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__attributesOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
<?php if (isset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c)): ?>
<?php $component = $__componentOriginal643fe1b47aec0b76658e1a0200b34b2c; ?>
<?php unset($__componentOriginal643fe1b47aec0b76658e1a0200b34b2c); ?>
<?php endif; ?>
                                    </div>
                                    <input type="tel" name="phone" value="<?php echo e(old('phone', $user->profile?->phone)); ?>"
                                        placeholder="08xxxxxx"
                                        class="w-full pl-14 pr-6 py-4 bg-slate-50/50 border border-slate-100 rounded-[1.25rem] text-sm font-bold text-slate-700 focus:bg-white focus:ring-4 focus:ring-slate-500/5 focus:border-slate-300 outline-none transition-all">
                                </div>
                            </div>
                        </div>

                        
                        <div
                            class="flex flex-col md:flex-row items-center justify-end gap-6 pt-10 border-t border-slate-50">
                            <a href="<?php echo e(route('profile.show')); ?>"
                                class="text-sm font-bold text-slate-400 hover:text-slate-600 transition-colors">
                                Cancel
                            </a>
                            <button type="submit"
                                class="w-full md:w-auto px-12 py-4 bg-gradient-to-r from-red-600 to-pink-500 text-white font-black rounded-2xl shadow-xl shadow-pink-500/30 hover:scale-105 transition transform active:scale-95 uppercase tracking-widest text-xs">
                                Save Changes
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <?php $__env->startPush('scripts'); ?>
        <script>
            // Logic: Photo Preview (Hanya untuk preview lokal di browser, tidak convert ke Base64 lagi)
            const uploadInput = document.getElementById('avatar-upload-input');
            const previewImg = document.getElementById('avatar-preview');
            const removeBtn = document.getElementById('btn-remove-photo');
            const removeInput = document.getElementById('remove-avatar-input');

            uploadInput.addEventListener('change', function() {
                const file = this.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        // Tampilkan preview di halaman
                        previewImg.src = e.target.result;

                        // Jika sebelumnya user klik remove, batalkan status remove-nya
                        if (removeInput) removeInput.value = "0";
                    }
                    reader.readAsDataURL(file);
                }
            });

            if (removeBtn) {
                removeBtn.addEventListener('click', function() {
                    // Kembalikan gambar ke default
                    previewImg.src = previewImg.dataset.default;

                    // Tandai bahwa foto dihapus untuk diproses Controller
                    if (removeInput) removeInput.value = "1";

                    // Bersihkan input file
                    uploadInput.value = "";
                });
            }
        </script>
    <?php $__env->stopPush(); ?>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/edit-profile.blade.php ENDPATH**/ ?>