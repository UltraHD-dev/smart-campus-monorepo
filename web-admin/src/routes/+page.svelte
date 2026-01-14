<script lang="ts">
  import DeviceCheck from '$lib/components/DeviceCheck.svelte';
  import { Building, Users, FileCheck, Upload, Shield, AlertCircle, Settings, BarChart } from 'lucide-svelte';
  import { onMount } from 'svelte';
  
  let stats = {
    организации: 0,
    заявки: 0,
    пользователи: 0,
    статус: 'онлайн'
  };
  
  let последниеЗаявки = [
    { id: 1, название: 'Технологический Университет', email: 'contact@utech.edu', статус: 'на рассмотрении', дата: '14.01.2024' },
    { id: 2, название: 'Бизнес Колледж', email: 'admin@bcollege.edu', статус: 'на рассмотрении', дата: '13.01.2024' },
    { id: 3, название: 'Медицинский Институт', email: 'info@medinstitute.edu', статус: 'просмотрено', дата: '12.01.2024' },
    { id: 4, название: 'Школа Искусств', email: 'art@school.edu', статус: 'на рассмотрении', дата: '14.01.2024' }
  ];
  
  onMount(() => {
    // Симуляция загрузки данных
    setTimeout(() => {
      stats = {
        организации: 42,
        заявки: 8,
        пользователи: 1247,
        статус: 'онлайн'
      };
    }, 800);
  });
  
  function одобритьЗаявку(id: number) {
    console.log('Одобряем заявку', id);
    последниеЗаявки = последниеЗаявки.filter(заявка => заявка.id !== id);
    stats.заявки -= 1;
  }
  
  function отклонитьЗаявку(id: number) {
    console.log('Отклоняем заявку', id);
    последниеЗаявки = последниеЗаявки.filter(заявка => заявка.id !== id);
    stats.заявки -= 1;
  }
</script>

<DeviceCheck strictMode={true} />

<svelte:head>
  <title>Smart Campus - Админ Панель</title>
  <meta name="description" content="Панель управления Smart Campus Platform" />
</svelte:head>

<div class="min-h-screen bg-gray-50">
  <!-- Шапка -->
  <header class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <div class="flex items-center space-x-3">
          <Building class="h-8 w-8 text-indigo-600" />
          <div>
            <h1 class="text-xl font-bold text-gray-900">Smart Campus Админ</h1>
            <p class="text-sm text-gray-500">Панель Супер-Администратора</p>
          </div>
        </div>
        
        <div class="flex items-center space-x-4">
          <div class="flex items-center bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm">
            <div class="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
            Система: {stats.статус}
          </div>
          <div class="relative">
            <div class="w-8 h-8 bg-indigo-100 rounded-full flex items-center justify-center">
              <span class="text-indigo-600 font-semibold">СА</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>

  <!-- Основной контент -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Статистика -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <!-- Организации -->
      <div class="bg-white rounded-xl shadow p-6 hover:shadow-md transition-shadow">
        <div class="flex items-center">
          <div class="p-3 bg-blue-100 rounded-lg mr-4">
            <Building class="h-6 w-6 text-blue-600" />
          </div>
          <div>
            <p class="text-sm text-gray-500">Организации</p>
            <p class="text-2xl font-bold text-gray-900">{stats.организации}</p>
          </div>
        </div>
        <div class="mt-4 pt-4 border-t border-gray-100">
          <a href="/admin/organizations" class="text-blue-600 hover:text-blue-800 text-sm font-medium">
            Смотреть все →
          </a>
        </div>
      </div>
      
      <!-- Заявки -->
      <div class="bg-white rounded-xl shadow p-6 hover:shadow-md transition-shadow">
        <div class="flex items-center">
          <div class="p-3 bg-yellow-100 rounded-lg mr-4">
            <FileCheck class="h-6 w-6 text-yellow-600" />
          </div>
          <div>
            <p class="text-sm text-gray-500">Заявки на рассмотрении</p>
            <p class="text-2xl font-bold text-gray-900">{stats.заявки}</p>
          </div>
        </div>
        <div class="mt-4 pt-4 border-t border-gray-100">
          <a href="/admin/applications" class="text-yellow-600 hover:text-yellow-800 text-sm font-medium">
            Рассмотреть сейчас →
          </a>
        </div>
      </div>
      
      <!-- Пользователи -->
      <div class="bg-white rounded-xl shadow p-6 hover:shadow-md transition-shadow">
        <div class="flex items-center">
          <div class="p-3 bg-green-100 rounded-lg mr-4">
            <Users class="h-6 w-6 text-green-600" />
          </div>
          <div>
            <p class="text-sm text-gray-500">Всего пользователей</p>
            <p class="text-2xl font-bold text-gray-900">{stats.пользователи}</p>
          </div>
        </div>
        <div class="mt-4 pt-4 border-t border-gray-100">
          <a href="/admin/users" class="text-green-600 hover:text-green-800 text-sm font-medium">
            Управлять пользователями →
          </a>
        </div>
      </div>
      
      <!-- Безопасность -->
      <div class="bg-white rounded-xl shadow p-6 hover:shadow-md transition-shadow">
        <div class="flex items-center">
          <div class="p-3 bg-purple-100 rounded-lg mr-4">
            <Shield class="h-6 w-6 text-purple-600" />
          </div>
          <div>
            <p class="text-sm text-gray-500">Статус безопасности</p>
            <p class="text-2xl font-bold text-green-600">Активен</p>
          </div>
        </div>
        <div class="mt-4 pt-4 border-t border-gray-100">
          <p class="text-purple-600 text-sm font-medium">Блокировка мобильных: ВКЛ</p>
        </div>
      </div>
    </div>

    <!-- Последние заявки -->
    <div class="bg-white rounded-xl shadow mb-8">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-semibold text-gray-800">Последние заявки</h2>
        <p class="text-sm text-gray-500">Организации, ожидающие одобрения</p>
      </div>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Организация</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Контакт</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Статус</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Дата</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Действия</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each последниеЗаявки as заявка (заявка.id)}
              <tr class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="font-medium text-gray-900">{заявка.название}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-gray-600">{заявка.email}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  {#if заявка.статус === 'на рассмотрении'}
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                      На рассмотрении
                    </span>
                  {:else}
                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                      {заявка.статус}
                    </span>
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-gray-500">{заявка.дата}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  {#if заявка.статус === 'на рассмотрении'}
                    <button 
                      on:click={() => одобритьЗаявку(заявка.id)}
                      class="text-green-600 hover:text-green-900 bg-green-50 hover:bg-green-100 px-3 py-1 rounded-md text-sm"
                    >
                      Одобрить
                    </button>
                    <button 
                      on:click={() => отклонитьЗаявку(заявка.id)}
                      class="text-red-600 hover:text-red-900 bg-red-50 hover:bg-red-100 px-3 py-1 rounded-md text-sm"
                    >
                      Отклонить
                    </button>
                  {:else}
                    <span class="text-gray-400">Завершено</span>
                  {/if}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      
      <div class="px-6 py-4 border-t border-gray-200">
        <a href="/admin/applications" class="text-indigo-600 hover:text-indigo-800 font-medium">
          Смотреть все заявки →
        </a>
      </div>
    </div>

    <!-- Уведомление безопасности -->
    <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-6 mb-8">
      <div class="flex items-start">
        <AlertCircle class="h-6 w-6 text-yellow-500 mr-3 mt-0.5" />
        <div>
          <h3 class="text-lg font-semibold text-yellow-800 mb-2">Важное уведомление безопасности</h3>
          <p class="text-yellow-700 mb-2">
            <strong>Доступ с мобильных телефонов ограничен</strong> для административных функций. 
            Эта функция безопасности предотвращает несанкционированный доступ с мобильных устройств.
          </p>
          <p class="text-yellow-600 text-sm">
            ✓ Разрешено: Компьютеры, Ноутбуки, Планшеты<br>
            ✗ Заблокировано: iPhone, Android телефоны, Windows Phone
          </p>
          <div class="mt-4 text-sm">
            <p class="text-gray-600">Ваше устройство: <code class="bg-yellow-100 px-2 py-1 rounded">{typeof navigator !== 'undefined' ? navigator.userAgent.substring(0, 60) + '...' : 'Определяется...'}</code></p>
          </div>
        </div>
      </div>
    </div>

    <!-- Быстрые действия -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div class="bg-white rounded-xl shadow p-6">
        <h3 class="font-semibold text-gray-800 mb-3">Массовая загрузка пользователей</h3>
        <p class="text-gray-600 text-sm mb-4">Загрузите CSV файл для создания нескольких пользователей одновременно.</p>
        <button class="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white font-medium py-2.5 rounded-lg flex items-center justify-center">
          <Upload class="h-5 w-5 mr-2" />
          Загрузить CSV
        </button>
      </div>
      
      <div class="bg-white rounded-xl shadow p-6">
        <h3 class="font-semibold text-gray-800 mb-3">Настройки системы</h3>
        <p class="text-gray-600 text-sm mb-4">Настройте параметры платформы и опции безопасности.</p>
        <a href="/admin/settings" class="block w-full bg-gray-800 hover:bg-gray-900 text-white font-medium py-2.5 rounded-lg text-center">
          Открыть настройки
        </a>
      </div>
      
      <div class="bg-white rounded-xl shadow p-6">
        <h3 class="font-semibold text-gray-800 mb-3">Мониторинг</h3>
        <p class="text-gray-600 text-sm mb-4">Просмотр метрик системы и панелей производительности.</p>
        <div class="flex space-x-3">
          <a href="http://localhost:13000" target="_blank" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 rounded-lg text-center text-sm">
            Grafana
          </a>
          <a href="http://localhost:15050" target="_blank" class="flex-1 bg-purple-600 hover:bg-purple-700 text-white font-medium py-2.5 rounded-lg text-center text-sm">
            PgAdmin
          </a>
          <a href="http://localhost:19090" target="_blank" class="flex-1 bg-orange-600 hover:bg-orange-700 text-white font-medium py-2.5 rounded-lg text-center text-sm">
            Prometheus
          </a>
        </div>
      </div>
    </div>
  </main>

  <!-- Подвал -->
  <footer class="bg-white border-t border-gray-200 mt-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <div class="text-gray-500 text-sm">
          Smart Campus Platform © 2024 | Панель Супер-Администратора
        </div>
        <div class="flex items-center space-x-6 mt-4 md:mt-0">
          <div class="text-sm text-gray-500">
            Бекенд: <span class="font-medium text-green-600">4/4 сервисов онлайн</span>
          </div>
          <div class="text-sm text-gray-500">
            База данных: <span class="font-medium text-green-600">Подключена</span>
          </div>
        </div>
      </div>
    </div>
  </footer>
</div>

<style>
  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Segoe UI', Arial, sans-serif;
  }
  
  code {
    font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  }
</style>
