<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ResolucionJuez.vue';

echo "📋 Actualizando ResolucionJuez.vue con paginación completa...\n\n";

$newContent = <<<'VUE'
<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="scale-balanced" /></div>
      <div class="module-view-info">
        <h1>Resolución de Juez</h1>
        <p>Registro y consulta</p>
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
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.folio"
                @keyup.enter="reload"
                placeholder="Número de folio"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resoluciones ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Cuenta</th>
                  <th>Periodo</th>
                  <th>Accesorios</th>
                  <th>Vigencia</th>
                  <th>CVE Pago</th>
                  <th>Observaciones</th>
                  <th>Usuario</th>
                  <th>Fecha Alta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_resolucion" class="row-hover">
                  <td><strong>{{ r.folio }}</strong></td>
                  <td>{{ r.cuenta }}</td>
                  <td><span class="badge badge-info">{{ r.periodo }}</span></td>
                  <td>{{ r.accesorios }}</td>
                  <td><span :class="getVigenciaClass(r.vigencia)">{{ r.vigencia }}</span></td>
                  <td>{{ r.cvepago }}</td>
                  <td class="observaciones-cell" :title="r.observaciones">
                    {{ truncateText(r.observaciones, 60) }}
                  </td>
                  <td>{{ r.usuario_alta }}</td>
                  <td>{{ formatDate(r.fecha_alta) }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="9" class="text-center text-muted">Sin resultados</td>
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
const OP_LIST = 'RECAUDADORA_RESOLUCION_JUEZ'

const { loading, execute } = useApi()
const filters = ref({ cuenta: '', folio: null })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Función para recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'clave_cuenta', tipo: 'C', valor: String(filters.value.cuenta || '') },
    { nombre: 'folio', tipo: 'I', valor: Number(filters.value.folio || 0) }
  ]

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
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar resoluciones:', e)
    rows.value = []
  }
}

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX')
}

// Truncar texto
function truncateText(text, maxLength) {
  if (!text) return 'N/A'
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

// Clase CSS según vigencia
function getVigenciaClass(vigencia) {
  if (vigencia === 'Vigente') return 'badge badge-success'
  if (vigencia === 'Cancelado') return 'badge badge-danger'
  if (vigencia === 'Activo') return 'badge badge-primary'
  return 'badge badge-secondary'
}

// No cargar automáticamente
// reload()
</script>

<style scoped>
.badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.badge-success {
  background-color: #28a745;
  color: #fff;
}

.badge-danger {
  background-color: #dc3545;
  color: #fff;
}

.badge-primary {
  background-color: #007bff;
  color: #fff;
}

.badge-info {
  background-color: #17a2b8;
  color: #fff;
}

.badge-secondary {
  background-color: #6c757d;
  color: #fff;
}

.observaciones-cell {
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  cursor: help;
}

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
echo "║         🎉 RESOLUCION JUEZ ACTUALIZADO 🎉                  ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "📋 CAMBIOS APLICADOS:\n";
echo "   ✅ Formato de parámetros corregido (nombre/tipo/valor)\n";
echo "   ✅ Paginación de 10 en 10 implementada\n";
echo "   ✅ Tabla HTML con 9 columnas específicas\n";
echo "   ✅ Procesamiento correcto de respuesta eResponse.data.result\n";
echo "   ✅ Formateo de fechas a formato español\n";
echo "   ✅ Truncado de observaciones con tooltip\n";
echo "   ✅ Badges de colores según vigencia\n";
echo "   ✅ Badge especial para periodo\n";
echo "   ✅ Controles de navegación de páginas\n";
echo "   ✅ Contador de registros\n";
echo "   ✅ Placeholders en inputs\n";
echo "\n";
echo "🎯 EJEMPLOS PARA PROBAR:\n";
echo "   1. Cuenta: 98925 → Folio 59, Periodo 2019/1 - 2022/2\n";
echo "   2. Cuenta: 376230 → Folio 58, Periodo 2013/1 - 2017/6\n";
echo "   3. Folio: 57 → Cuenta 247299, Periodo 2019/1 - 2022/4\n";
echo "   4. Sin filtros → Todos los registros (59) con paginación\n";
echo "\n";
echo "🚀 Ahora recarga la página y prueba el módulo\n";
echo "\n";
