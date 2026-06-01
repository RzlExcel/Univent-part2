<?php $__env->startSection('title', 'EO Requests Management - Admin'); ?>

<?php $__env->startSection('content'); ?>
<div class="min-h-screen bg-slate-50/50 pt-28 pb-20 px-4 relative overflow-hidden" x-data="{ selectedUser: null, openDetail: false, activeTab: 'pending' }">
    
    <div class="absolute -top-24 -left-24 w-96 h-96 bg-red-100 rounded-full blur-3xl opacity-50 -z-10"></div>
    <div class="absolute top-1/2 -right-24 w-80 h-80 bg-pink-100 rounded-full blur-3xl opacity-40 -z-10"></div>

    <div class="max-w-7xl mx-auto relative">
        
        <div class="mb-8 text-center md:text-left">
            <h1 class="text-3xl font-extrabold text-slate-900 mb-2 italic tracking-tight">Admin Workspace</h1>
            <p class="text-slate-500 font-medium">Kelola seluruh ekosistem Univent dari panel ini.</p>
        </div>

        
        <div class="flex p-1.5 mb-10 bg-slate-200/50 rounded-2xl w-fit border border-slate-200/50">
            <a href="<?php echo e(route('admin.event-list')); ?>" class="px-8 py-3 rounded-xl text-sm font-bold text-slate-500 hover:text-slate-700 transition-all flex items-center gap-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                Event List
            </a>
            <a href="<?php echo e(route('admin.eo-requests')); ?>" class="px-8 py-3 rounded-xl text-sm font-bold bg-white text-red-600 shadow-sm border border-slate-200 flex items-center gap-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                EO Requests
            </a>
        </div>

        
        <div class="flex p-1.5 mb-8 bg-slate-100/80 rounded-2xl w-fit border border-slate-200/50 items-center">
            <button @click="activeTab = 'pending'" 
                    :class="activeTab === 'pending' ? 'bg-white text-red-600 shadow-sm border border-slate-200/50' : 'text-slate-500 hover:text-slate-700'" 
                    class="px-6 py-2 rounded-xl text-sm font-bold transition-all">
                Menunggu <span :class="activeTab === 'pending' ? 'text-red-400' : 'text-slate-400'">(<?php echo e($pendingRequests->count()); ?>)</span>
            </button>
            
            <button @click="activeTab = 'approved'" 
                    :class="activeTab === 'approved' ? 'bg-white text-red-600 shadow-sm border border-slate-200/50' : 'text-slate-500 hover:text-slate-700'" 
                    class="px-6 py-2 rounded-xl text-sm font-bold transition-all">
                Disetujui <span :class="activeTab === 'approved' ? 'text-red-400' : 'text-slate-400'">(<?php echo e($approvedRequests->count()); ?>)</span>
            </button>
            
            <button @click="activeTab = 'rejected'" 
                    :class="activeTab === 'rejected' ? 'bg-white text-red-600 shadow-sm border border-slate-200/50' : 'text-slate-500 hover:text-slate-700'" 
                    class="px-6 py-2 rounded-xl text-sm font-bold transition-all">
                Ditolak <span :class="activeTab === 'rejected' ? 'text-red-400' : 'text-slate-400'">(<?php echo e($rejectedRequests->count()); ?>)</span>
            </button>
            
            <button @click="activeTab = 'all'" 
                    :class="activeTab === 'all' ? 'bg-white text-red-600 shadow-sm border border-slate-200/50' : 'text-slate-500 hover:text-slate-700'" 
                    class="px-6 py-2 rounded-xl text-sm font-bold transition-all">
                Semua <span :class="activeTab === 'all' ? 'text-red-400' : 'text-slate-400'">(<?php echo e($allRequests->count()); ?>)</span>
            </button>
        </div>

        
        <div class="bg-white rounded-[2rem] border border-slate-100 shadow-xl shadow-slate-200/40 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse whitespace-nowrap">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 text-xs uppercase tracking-wider font-extrabold">
                            <th class="p-6">Profil Pengguna</th>
                            <th class="p-6">Tipe & Organisasi</th>
                            <th class="p-6">Status</th>
                            <th class="p-6 text-right">Aksi</th>
                        </tr>
                    </thead>
                    
                    
                    <?php
                        $tabData = [
                            'pending' => $pendingRequests,
                            'approved' => $approvedRequests,
                            'rejected' => $rejectedRequests,
                            'all' => $allRequests
                        ];
                    ?>

                    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__currentLoopData = $tabData; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $tabName => $requestsList): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                        <tbody x-show="activeTab === '<?php echo e($tabName); ?>'" class="divide-y divide-slate-100" style="display: <?php echo e($tabName === 'pending' ? 'table-row-group' : 'none'); ?>;">
                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::openLoop(); ?><?php endif; ?><?php $__empty_1 = true; $__currentLoopData = $requestsList; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $req): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::startLoopIteration(); ?><?php endif; ?>
                                <tr class="hover:bg-slate-50/50 transition duration-150">
                                    <td class="p-6">
                                        <div class="flex items-center gap-4">
                                            <div class="h-10 w-10 rounded-full bg-slate-200 overflow-hidden shrink-0 border border-slate-200">
                                                <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($req->avatar): ?>
                                                    <img src="data:image/jpeg;base64,<?php echo e($req->avatar); ?>" class="h-full w-full object-cover">
                                                <?php else: ?>
                                                    <img src="<?php echo e(asset('images/default-avatar.svg')); ?>" class="h-full w-full object-cover">
                                                <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                                            </div>
                                            <div>
                                                <p class="text-sm font-extrabold text-slate-900"><?php echo e($req->name); ?></p>
                                                <p class="text-xs text-slate-500"><?php echo e($req->email); ?></p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="p-6">
                                        <p class="text-sm font-bold text-slate-700"><?php echo e($req->eo_org_name ?? '-'); ?></p>
                                        <p class="text-[10px] uppercase tracking-widest font-extrabold text-red-500"><?php echo e($req->eo_org_type ?? '-'); ?></p>
                                    </td>
                                    
                                    
                                    <td class="p-6">
                                        <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($req->eo_request_status === 'pending'): ?>
                                            <span class="px-4 py-1.5 bg-yellow-100 text-yellow-600 text-[11px] font-extrabold uppercase tracking-widest rounded-full">
                                                PENDING
                                            </span>
                                        <?php elseif($req->eo_request_status === 'approved'): ?>
                                            <span class="px-4 py-1.5 bg-green-100 text-green-600 text-[11px] font-extrabold uppercase tracking-widest rounded-full">
                                                APPROVED
                                            </span>
                                        <?php elseif($req->eo_request_status === 'rejected'): ?>
                                            <span class="px-4 py-1.5 bg-red-100 text-red-600 text-[11px] font-extrabold uppercase tracking-widest rounded-full">
                                                REJECTED
                                            </span>
                                        <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                                    </td>

                                    
                                    <td class="p-6 text-right">
                                        <div class="flex items-center justify-end gap-2">
                                            
                                            
                                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($req->eo_request_status !== 'approved'): ?>
                                                <form action="<?php echo e(route('admin.eo-requests.approve', $req->id)); ?>" method="POST" class="m-0">
                                                    <?php echo csrf_field(); ?>
                                                    <button type="submit" onclick="return confirm('Setujui pengajuan ini?')" class="w-9 h-9 flex items-center justify-center bg-green-100 text-green-500 rounded-xl hover:bg-green-200 transition-all" title="Approve">
                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"></path></svg>
                                                    </button>
                                                </form>
                                            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>

                                            
                                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if BLOCK]><![endif]--><?php endif; ?><?php if($req->eo_request_status !== 'rejected'): ?>
                                                <form action="<?php echo e(route('admin.eo-requests.reject', $req->id)); ?>" method="POST" class="m-0">
                                                    <?php echo csrf_field(); ?>
                                                    <button type="submit" onclick="return confirm('Tolak pengajuan ini?')" class="w-9 h-9 flex items-center justify-center bg-red-100 text-red-500 rounded-xl hover:bg-red-200 transition-all" title="Reject">
                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"></path></svg>
                                                    </button>
                                                </form>
                                            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>

                                            
                                            <button @click="selectedUser = <?php echo e(json_encode($req)); ?>; openDetail = true" class="w-9 h-9 flex items-center justify-center bg-slate-100 text-slate-600 rounded-xl hover:bg-slate-200 transition-all" title="Detail">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                            </button>

                                            
                                            <form action="#" method="POST" class="m-0">
                                                <?php echo csrf_field(); ?>
                                                <?php echo method_field('DELETE'); ?>
                                                <button type="button" onclick="alert('Fitur hapus segera hadir!')" class="w-9 h-9 flex items-center justify-center bg-white border border-slate-200 text-slate-400 rounded-xl hover:bg-slate-50 hover:text-red-500 transition-all" title="Hapus">
                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                                                </button>
                                            </form>

                                        </div>
                                    </td>
                                </tr>
                            <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                                <tr>
                                    <td colspan="4" class="p-16 text-center text-slate-400 font-bold italic">Antrean Kosong</td>
                                </tr>
                            <?php endif; ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php endif; ?>
                        </tbody>
                    <?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::endLoop(); ?><?php endif; ?><?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?><?php if(\Livewire\Mechanisms\ExtendBlade\ExtendBlade::isRenderingLivewireComponent()): ?><!--[if ENDBLOCK]><![endif]--><?php \Livewire\Features\SupportCompiledWireKeys\SupportCompiledWireKeys::closeLoop(); ?><?php endif; ?>
                </table>
            </div>
        </div>
    </div>

    
    
    
    <div x-show="openDetail" style="display: none;" class="fixed inset-0 z-[110] flex items-center justify-center bg-slate-900/40 backdrop-blur-sm p-4">
        <div @click.away="openDetail = false" 
             x-show="openDetail"
             x-transition:enter="transition ease-out duration-300"
             x-transition:enter-start="opacity-0 translate-y-8 scale-95"
             x-transition:enter-end="opacity-100 translate-y-0 scale-100"
             class="bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl relative overflow-hidden">
            
            <div class="absolute top-0 left-0 w-full h-1.5 bg-gradient-to-r from-red-600 to-pink-500"></div>
            <button @click="openDetail = false" class="absolute top-4 right-4 p-2 text-slate-400 hover:text-slate-600 transition hover:bg-slate-50 rounded-full">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
            
            <h3 class="text-xl font-extrabold text-slate-900 mb-6 italic">Verifikasi Pengajuan</h3>
            
            <template x-if="selectedUser">
                <div class="space-y-5">
                    <div class="flex items-center gap-4 p-3 bg-slate-50 rounded-2xl border border-slate-100">
                        <div class="h-12 w-12 rounded-full bg-slate-200 overflow-hidden border border-slate-200">
                            <img :src="selectedUser.avatar ? 'data:image/jpeg;base64,' + selectedUser.avatar : '<?php echo e(asset('images/default-avatar.svg')); ?>'" class="h-full w-full object-cover">
                        </div>
                        <div>
                            <p class="text-sm font-extrabold text-slate-900" x-text="selectedUser.name"></p>
                            <p class="text-xs text-slate-500" x-text="selectedUser.email"></p>
                        </div>
                    </div>

                    <div>
                        <label class="text-[10px] uppercase font-bold text-slate-400 tracking-widest">Organisasi</label>
                        <p class="text-sm font-bold text-slate-800" x-text="(selectedUser.eo_org_type || '-') + ' - ' + (selectedUser.eo_org_name || '-')"></p>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="text-[10px] uppercase font-bold text-slate-400 tracking-widest">WhatsApp</label>
                            <a :href="'https://wa.me/' + (selectedUser.eo_phone ? selectedUser.eo_phone.replace(/[^0-9]/g, '').replace(/^0/, '62') : '')" 
                               target="_blank" class="flex items-center gap-1.5 text-sm font-bold text-red-600 hover:underline">
                                <span x-text="selectedUser.eo_phone || '-'"></span>
                            </a>
                        </div>
                        <div>
                            <label class="text-[10px] uppercase font-bold text-slate-400 tracking-widest">Instagram</label>
                            <a :href="'https://instagram.com/' + (selectedUser.eo_instagram ? selectedUser.eo_instagram.replace('@', '') : '')" 
                               target="_blank" class="flex items-center gap-1.5 text-sm font-bold text-slate-800 hover:underline">
                                <span x-text="selectedUser.eo_instagram || '-'"></span>
                            </a>
                        </div>
                    </div>
                </div>
            </template>

            <div class="mt-8 flex gap-3 pt-4 border-t border-slate-100">
                <form :action="'/admin/eo-requests/' + selectedUser?.id + '/reject'" method="POST" class="flex-1" x-show="selectedUser?.eo_request_status !== 'rejected'">
                    <?php echo csrf_field(); ?>
                    <button type="submit" onclick="return confirm('Tolak pengajuan ini?')" class="w-full py-3 bg-white border border-slate-200 text-slate-600 font-bold rounded-xl text-sm hover:bg-red-50 hover:text-red-600 transition">
                        Tolak
                    </button>
                </form>

                <form :action="'/admin/eo-requests/' + selectedUser?.id + '/approve'" method="POST" class="flex-1" x-show="selectedUser?.eo_request_status !== 'approved'">
                    <?php echo csrf_field(); ?>
                    <button type="submit" onclick="return confirm('Setujui user menjadi Event Organizer?')" class="w-full py-3 bg-gradient-to-r from-red-600 to-pink-500 text-white font-bold rounded-xl text-sm hover:scale-105 transition shadow-lg shadow-pink-500/20">
                        Setujui
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
<?php $__env->stopSection(); ?>
<?php echo $__env->make('layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH R:\ABp tubes\univent2.0\ABP\univent 2.0\resources\views/admin/eo-requests.blade.php ENDPATH**/ ?>