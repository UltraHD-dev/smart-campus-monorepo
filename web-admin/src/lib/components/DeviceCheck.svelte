<script lang="ts">
  import { onMount } from 'svelte';
  import { browser } from '$app/environment';
  import { goto } from '$app/navigation';
  import { AlertTriangle, Monitor, Smartphone, Tablet } from 'lucide-svelte';
  
  export let strictMode = true;
  export let showWarning = true;
  export let testMode = false; // Режим тестирования
  
  let isMobilePhone = false;
  let showModal = false;
  let userAgent = '';
  let deviceType = 'Определяется...';
  
  // Функция проверки устройства
  function checkDevice() {
    if (!browser) return;
    
    userAgent = navigator.userAgent.toLowerCase();
    
    // Для тестирования через DevTools
    if (testMode) {
      console.log('🔍 Тестовый режим активирован');
      // Можно принудительно установить mobile user-agent для тестирования
      // userAgent = 'mozilla/5.0 (iphone; cpu iphone os 14_0 like mac os x) applewebkit/605.1.15';
    }
    
    // Паттерны для мобильных телефонов
    const mobilePatterns = [
      /iphone/i,
      /android.*mobile/i,
      /windows phone/i,
      /blackberry/i,
      /opera mini/i,
      /mobile.*firefox/i,
      /mobile/i
    ];
    
    // Паттерны для разрешенных устройств
    const allowedPatterns = [
      /ipad/i,
      /tablet/i,
      /android(?!.*mobile)/i, // Android но не mobile
      /windows nt/i,
      /macintosh/i,
      /mac os/i,
      /linux/i,
      /chrome.*safari/i,
      /x11/i, // Linux X11
      /playbook/i,
      /kindle/i,
      /silk/i
    ];
    
    // Проверяем на мобильный телефон
    const isPhone = mobilePatterns.some(pattern => pattern.test(userAgent));
    
    // Проверяем на разрешенное устройство
    const isAllowedDevice = allowedPatterns.some(pattern => pattern.test(userAgent));
    
    // Определяем тип устройства для отображения
    if (/iphone/i.test(userAgent)) deviceType = 'iPhone';
    else if (/android.*mobile/i.test(userAgent)) deviceType = 'Android телефон';
    else if (/ipad|tablet/i.test(userAgent)) deviceType = 'Планшет';
    else if (/windows nt|macintosh|mac os|linux/i.test(userAgent)) deviceType = 'Компьютер/Ноутбук';
    else deviceType = 'Неизвестное устройство';
    
    isMobilePhone = isPhone && !isAllowedDevice;
    
    console.log('📱 Проверка устройства:', {
      userAgent: userAgent.substring(0, 100) + '...',
      deviceType,
      isPhone,
      isAllowedDevice,
      isMobilePhone,
      strictMode
    });
    
    if ((isMobilePhone || testMode) && strictMode && showWarning) {
      showModal = true;
      console.warn('🚫 Обнаружен мобильный телефон! Доступ к админ-панели ограничен.');
    }
  }
  
  onMount(() => {
    checkDevice();
    
    // Добавляем кнопку для тестирования в dev-режиме
    if (browser && import.meta.env.DEV) {
      // Добавляем глобальную функцию для тестирования
      (window as any).testMobileBlock = () => {
        console.log('🛠️ Принудительная проверка мобильного устройства...');
        userAgent = 'mozilla/5.0 (iphone; cpu iphone os 14_0 like mac os x) applewebkit/605.1.15';
        showModal = true;
      };
      
      console.log('ℹ️ Для тестирования блокировки выполните в консоли: testMobileBlock()');
    }
  });
  
  function handleContinue() {
    showModal = false;
    console.log('⚠️ Пользователь продолжил с мобильного устройства');
  }
  
  function handleRedirect() {
    goto('/mobile-blocked');
  }
  
  function simulateMobile() {
    userAgent = 'mozilla/5.0 (iphone; cpu iphone os 14_0 like mac os x) applewebkit/605.1.15';
    deviceType = 'iPhone (тестовый режим)';
    showModal = true;
  }
</script>

{#if browser && showModal}
  <div 
    class="fixed inset-0 bg-black/80 backdrop-blur-md z-[9999] flex items-center justify-center p-4"
    style="animation: fadeIn 0.3s ease-out;"
  >
    <div class="bg-white rounded-2xl shadow-2xl p-6 max-w-md w-full transform transition-all duration-300 scale-100 border-4 border-red-500">
      <div class="text-center mb-5">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
          <AlertTriangle class="h-8 w-8 text-red-600" />
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Доступ Заблокирован</h2>
        <p class="text-gray-600 mb-4">
          Админ-панель недоступна с мобильных телефонов по соображениям безопасности.
        </p>
      </div>
      
      <div class="mb-5">
        <div class="grid grid-cols-2 gap-3 mb-4">
          <div class="text-center p-3 bg-green-50 rounded-lg border border-green-200">
            <Monitor class="h-6 w-6 text-green-600 mx-auto mb-2" />
            <p class="text-sm font-medium text-green-700">Компьютер</p>
            <p class="text-xs text-green-600">Разрешено</p>
          </div>
          <div class="text-center p-3 bg-green-50 rounded-lg border border-green-200">
            <Tablet class="h-6 w-6 text-green-600 mx-auto mb-2" />
            <p class="text-sm font-medium text-green-700">Планшет</p>
            <p class="text-xs text-green-600">Разрешено</p>
          </div>
          <div class="text-center p-3 bg-red-50 rounded-lg border border-red-200">
            <Smartphone class="h-6 w-6 text-red-600 mx-auto mb-2" />
            <p class="text-sm font-medium text-red-700">iPhone</p>
            <p class="text-xs text-red-600">Заблокировано</p>
          </div>
          <div class="text-center p-3 bg-red-50 rounded-lg border border-red-200">
            <Smartphone class="h-6 w-6 text-red-600 mx-auto mb-2" />
            <p class="text-sm font-medium text-red-700">Android</p>
            <p class="text-xs text-red-600">Заблокировано</p>
          </div>
        </div>
        
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
          <p class="text-sm text-yellow-800 mb-1">
            <strong>Обнаруженное устройство:</strong> {deviceType}
          </p>
          <p class="text-xs font-mono bg-yellow-100 p-2 rounded truncate text-yellow-900">
            {userAgent.substring(0, 80)}...
          </p>
        </div>
      </div>
      
      <div class="space-y-3">
        <button
          on:click={handleContinue}
          class="w-full bg-gray-800 hover:bg-gray-900 text-white font-medium py-3 rounded-lg transition-colors"
        >
          Я понимаю (Продолжить на свой страх и риск)
        </button>
        
        <button
          on:click={handleRedirect}
          class="w-full border border-gray-300 text-gray-700 hover:bg-gray-50 font-medium py-3 rounded-lg transition-colors"
        >
          Перейти на страницу блокировки
        </button>
        
        {#if import.meta.env.DEV}
          <button
            on:click={simulateMobile}
            class="w-full border-2 border-dashed border-blue-300 text-blue-600 hover:bg-blue-50 font-medium py-2 rounded-lg transition-colors text-sm"
          >
            🧪 Тест: Сымитировать мобильное устройство
          </button>
        {/if}
      </div>
      
      <div class="mt-5 pt-4 border-t border-gray-200 text-center">
        <p class="text-xs text-gray-500">
          Smart Campus Platform • Система безопасности
        </p>
      </div>
    </div>
  </div>
{/if}

{#if browser && import.meta.env.DEV}
  <!-- Кнопка для тестирования в dev-режиме -->
  <div class="fixed bottom-4 right-4 z-50">
    <button
      on:click={simulateMobile}
      class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg shadow-lg flex items-center space-x-2 text-sm font-medium"
      title="Тест блокировки мобильных устройств"
    >
      <Smartphone class="h-4 w-4" />
      <span>Тест блокировки</span>
    </button>
  </div>
{/if}

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
      backdrop-filter: blur(0px);
    }
    to {
      opacity: 1;
      backdrop-filter: blur(8px);
    }
  }
</style>
