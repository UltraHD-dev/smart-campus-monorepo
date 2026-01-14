<script lang="ts">
  import { AlertTriangle, Monitor, Smartphone, Tablet, ArrowLeft, Home } from 'lucide-svelte';
  import { onMount } from 'svelte';
  
  let userAgent = '';
  let типУстройства = 'Определяется...';
  
  onMount(() => {
    if (typeof window !== 'undefined') {
      userAgent = navigator.userAgent;
      const ua = userAgent.toLowerCase();
      
      if (/iphone|android.*mobile|windows phone/.test(ua)) {
        типУстройства = 'Мобильный телефон';
      } else if (/ipad|tablet/.test(ua)) {
        типУстройства = 'Планшет';
      } else if (/windows nt|macintosh|linux/.test(ua)) {
        типУстройства = 'Компьютер/Ноутбук';
      }
    }
  });
  
  function вернутьсяНазад() {
    window.history.back();
  }
  
  function перейтиНаГлавную() {
    window.location.href = '/';
  }
</script>

<svelte:head>
  <title>Доступ Заблокирован - Smart Campus Админ</title>
</svelte:head>

<div class="min-h-screen bg-gradient-to-br from-red-50 to-orange-50 flex items-center justify-center p-4">
  <div class="max-w-md w-full">
    <div class="bg-white rounded-2xl shadow-2xl p-8 text-center">
      <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 rounded-full mb-6">
        <AlertTriangle class="h-10 w-10 text-red-600" />
      </div>
      
      <h1 class="text-3xl font-bold text-gray-900 mb-3">Доступ Заблокирован</h1>
      <p class="text-gray-600 mb-6">
        Админ-панель недоступна с мобильных телефонов по соображениям безопасности.
      </p>
      
      <div class="bg-gray-50 rounded-xl p-5 mb-6">
        <div class="grid grid-cols-3 gap-4 mb-4">
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-green-100 rounded-full mb-2">
              <Monitor class="h-6 w-6 text-green-600" />
            </div>
            <p class="text-sm font-medium text-green-700">Компьютер</p>
            <p class="text-xs text-gray-500">Разрешено</p>
          </div>
          
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-green-100 rounded-full mb-2">
              <Monitor class="h-6 w-6 text-green-600" />
            </div>
            <p class="text-sm font-medium text-green-700">Ноутбук</p>
            <p class="text-xs text-gray-500">Разрешено</p>
          </div>
          
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-yellow-100 rounded-full mb-2">
              <Tablet class="h-6 w-6 text-yellow-600" />
            </div>
            <p class="text-sm font-medium text-yellow-700">Планшет</p>
            <p class="text-xs text-gray-500">Разрешено</p>
          </div>
        </div>
        
        <div class="grid grid-cols-2 gap-4">
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-red-100 rounded-full mb-2">
              <Smartphone class="h-6 w-6 text-red-600" />
            </div>
            <p class="text-sm font-medium text-red-700">iPhone</p>
            <p class="text-xs text-gray-500">Заблокировано</p>
          </div>
          
          <div class="text-center">
            <div class="inline-flex items-center justify-center w-12 h-12 bg-red-100 rounded-full mb-2">
              <Smartphone class="h-6 w-6 text-red-600" />
            </div>
            <p class="text-sm font-medium text-red-700">Android</p>
            <p class="text-xs text-gray-500">Заблокировано</p>
          </div>
        </div>
      </div>
      
      <div class="bg-blue-50 rounded-lg p-4 mb-6">
        <p class="text-sm text-blue-800 mb-2">📱 <strong>Обнаруженное устройство:</strong> {типУстройства}</p>
        <p class="text-xs text-blue-600 font-mono bg-blue-100 p-2 rounded truncate">{userAgent.substring(0, 100)}...</p>
      </div>
      
      <div class="space-y-3">
        <button
          on:click={вернутьсяНазад}
          class="w-full bg-red-600 hover:bg-red-700 text-white font-medium py-3 rounded-lg transition-colors flex items-center justify-center"
        >
          <ArrowLeft class="h-4 w-4 mr-2" />
          Назад
        </button>
        
        <button
          on:click={перейтиНаГлавную}
          class="w-full border border-gray-300 text-gray-700 hover:bg-gray-50 font-medium py-3 rounded-lg transition-colors flex items-center justify-center"
        >
          <Home class="h-4 w-4 mr-2" />
          Попробовать версию для компьютера
        </button>
      </div>
      
      <div class="mt-6 pt-6 border-t border-gray-200">
        <p class="text-sm text-gray-500">
          Для получения помощи, пожалуйста, используйте компьютер или свяжитесь с системным администратором.
        </p>
      </div>
    </div>
    
    <div class="mt-6 text-center">
      <p class="text-sm text-gray-500">
        Smart Campus Platform • Система безопасности • © 2024
      </p>
    </div>
  </div>
</div>
