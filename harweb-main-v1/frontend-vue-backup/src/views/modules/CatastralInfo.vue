<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-map fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Catastral</h1>
              <p class="fs-5 text-muted">Sistema Integral de Gestión Catastral y Registro de Propiedades</p>
            </div>
          </div>
          <div>
            <router-link 
              to="/" 
              class="btn btn-outline-secondary d-flex align-items-center"
            >
              <i class="fas fa-arrow-left me-2"></i>
              Volver al Dashboard
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- Contenido Principal -->
    <div class="container-fluid py-5">

          <!-- Quick Stats -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">156</div>
              <div class="text-sm text-gray-600">Componentes</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">89</div>
              <div class="text-sm text-gray-600">Formularios</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">420</div>
              <div class="text-sm text-gray-600">Procedimientos SQL</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">85</div>
              <div class="text-sm text-gray-600">Documentos</div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Features Section -->
        <div class="bg-white shadow-lg rounded-xl p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <i class="fas fa-star text-yellow-500 mr-3"></i>
            Funcionalidades Principales
          </h2>
          <ul class="space-y-4">
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Registro integral de propiedades y predios urbanos y rurales</span>
            </li>
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Gestión completa de avalúos y valuaciones catastrales</span>
            </li>
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Control de transferencias de dominio y cambios de propietario</span>
            </li>
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Administración de cartografía digital y sistema de coordenadas</span>
            </li>
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Generación automatizada de constancias y certificaciones</span>
            </li>
            <li class="flex items-start">
              <div class="w-2 h-2 bg-emerald-500 rounded-full mt-2 mr-4 flex-shrink-0"></div>
              <span class="text-gray-700">Reportes estadísticos y análisis territorial completo</span>
            </li>
          </ul>
        </div>

        <!-- Documentation Section -->
        <div class="bg-white shadow-lg rounded-xl p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <i class="fas fa-book text-blue-500 mr-3"></i>
            Componentes Principales
          </h2>
          <div class="space-y-4">
            <div class="p-4 bg-gray-50 rounded-lg">
              <h3 class="font-semibold text-gray-900 mb-2">🏠 Registro de Propiedades</h3>
              <p class="text-gray-600 text-sm">Gestión integral de predios urbanos y rurales</p>
            </div>
            <div class="p-4 bg-gray-50 rounded-lg">
              <h3 class="font-semibold text-gray-900 mb-2">💰 Avalúos y Valuaciones</h3>
              <p class="text-gray-600 text-sm">Sistema de valuación catastral automatizada</p>
            </div>
            <div class="p-4 bg-gray-50 rounded-lg">
              <h3 class="font-semibold text-gray-900 mb-2">📋 Transferencias</h3>
              <p class="text-gray-600 text-sm">Control de cambios de propietario y dominio</p>
            </div>
            <div class="p-4 bg-gray-50 rounded-lg">
              <h3 class="font-semibold text-gray-900 mb-2">🗺️ Cartografía Digital</h3>
              <p class="text-gray-600 text-sm">Mapeo territorial y sistema de coordenadas</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Technical Details -->
      <div class="mt-8 bg-white shadow-lg rounded-xl p-8">
        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
          <i class="fas fa-chart-line text-gray-500 mr-3"></i>
          Estadísticas del Sistema
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div class="text-center">
            <div class="text-3xl font-bold text-emerald-600 mb-2">85</div>
            <div class="text-gray-600">Documentos</div>
            <div class="text-gray-500 text-sm mt-1">Documentación completa</div>
          </div>
          <div class="text-center">
            <div class="text-3xl font-bold text-green-600 mb-2">35</div>
            <div class="text-gray-600">Casos de Uso</div>
            <div class="text-gray-500 text-sm mt-1">Procesos definidos</div>
          </div>
          <div class="text-center">
            <div class="text-3xl font-bold text-blue-600 mb-2">28</div>
            <div class="text-gray-600">Casos de Prueba</div>
            <div class="text-gray-500 text-sm mt-1">Validaciones automatizadas</div>
          </div>
          <div class="text-center">
            <div class="text-3xl font-bold text-teal-600 mb-2">25</div>
            <div class="text-gray-600">Reportes</div>
            <div class="text-gray-500 text-sm mt-1">Análisis territorial</div>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-8 flex justify-center space-x-4">
        <button 
          @click="$router.push('/dashboard')"
          class="bg-gray-600 text-white px-6 py-3 rounded-lg hover:bg-gray-700 transition-colors duration-200 inline-flex items-center"
        >
          <i class="fas fa-arrow-left mr-2"></i>
          Volver al Dashboard
        </button>
        <button 
          @click="$router.push('/catastral/acceso')"
          class="bg-emerald-600 text-white px-6 py-3 rounded-lg hover:bg-emerald-700 transition-colors duration-200 inline-flex items-center"
        >
          <i class="fas fa-map mr-2"></i>
          Acceder al Sistema
        </button>
      </div>

      <!-- RefactorX Branding -->
      <div class="mt-8 text-center">
        <div class="bg-white shadow-lg rounded-xl p-6">
          <div class="flex items-center justify-center mb-4">
            <div class="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mr-4">
              <span class="text-white font-bold text-lg">R</span>
            </div>
            <div class="text-left">
              <div class="text-xl font-bold text-gray-900">RefactorX</div>
              <div class="text-gray-600">Sistema Catastral - Migrado de Delphi</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatastralInfo'
}
</script>