<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/SdosFavor_CtrlExp.vue';

echo "📋 Agregando paginación a SdosFavor_CtrlExp.vue...\n\n";

$newContent = <<<'VUE'
<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="folder" /></div>
      <div class="module-view-info">
        <h1>Control de Expedientes (Saldos Favor)</h1>
        <p>Consulta y control</p>
      </div>
    </div>
    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="reload"
                placeholder="Ingrese cuenta"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="isSearchDisabled || loading"
              @click="reload"
            >
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Expedientes ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ r[col] }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td :colspan="columns.length" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_SDOSFAVOR_CTRLEXP'

const { loading, execute } = useApi()
const filters = ref({ cuenta: '' })
const rows = ref([])
const columns = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Computed para deshabilitar botón si no hay cuenta
const isSearchDisabled = computed(() => !filters.value.cuenta || filters.value.cuenta.trim() === '')

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

async function reload() {
  const params = [{ nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }]

  try {
    const response = await execute(OP_LIST, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta según la estructura de la API
    let arr = []

    // La API puede retornar diferentes estructuras
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    columns.value = arr.length ? Object.keys(arr[0]) : []
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar expedientes:', e)
    rows.value = []
    columns.value = []
  }
}
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 14px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 15px;
}

.pagination-page {
  color: #495057;
  font-weight: 500;
}

.btn-pagination {
  padding: 8px 16px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>

VUE;

file_put_contents($file, $newContent);

echo "✅ Archivo actualizado exitosamente\n\n";

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║         🎉 PAGINACIÓN AGREGADA 🎉                          ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "📋 CAMBIOS APLICADOS:\n";
echo "   ✅ Paginación de 10 en 10 implementada\n";
echo "   ✅ Procesamiento correcto de respuesta eResponse.data.result\n";
echo "   ✅ Variables de paginación agregadas\n";
echo "   ✅ Computed properties para paginación\n";
echo "   ✅ Controles de navegación (Anterior/Siguiente)\n";
echo "   ✅ Contador de registros en encabezado\n";
echo "   ✅ Indicador de página actual\n";
echo "   ✅ Botones deshabilitados cuando no hay más páginas\n";
echo "   ✅ Reset a página 1 al hacer nueva búsqueda\n";
echo "   ✅ Console.log para debugging\n";
echo "   ✅ Estilos CSS para paginación\n";
echo "\n";
echo "🎯 FUNCIONALIDADES:\n";
echo "   • Muestra 10 registros por página\n";
echo "   • Navegación entre páginas\n";
echo "   • Contador \"Mostrando X - Y de Z registros\"\n";
echo "   • Indicador \"Página X de Y\"\n";
echo "   • Botón Buscar deshabilitado si no hay cuenta\n";
echo "\n";
echo "🚀 Ahora recarga la página y prueba el módulo\n";
echo "\n";
