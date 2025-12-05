<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/sfrm_calificacionQR.vue';

echo "📋 Actualizando sfrm_calificacionQR.vue con paginación completa...\n\n";

$newContent = <<<'VUE'
<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="qrcode" />
      </div>
      <div class="module-view-info">
        <h1>Calificación QR</h1>
        <p>Consulta de calificaciones de multas</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda de Calificaciones</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta (ID Multa)</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.cuenta"
                placeholder="ID de multa"
                @keyup.enter="buscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio (Número de Acta)</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.folio"
                placeholder="Número de acta"
                @keyup.enter="buscar"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !isFormValid"
              @click="buscar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="rows.length > 0 || hasSearched">
        <div class="municipal-card-header">
          <h5>Calificaciones ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" v-if="rows.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Folio</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Calificación</th>
                  <th>Multa</th>
                  <th>Total</th>
                  <th>Tipo</th>
                  <th>Usuario</th>
                  <th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_multa" class="row-hover">
                  <td><strong>{{ r.id_multa }}</strong></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td class="text-right">${{ formatMoney(r.calificacion) }}</td>
                  <td class="text-right">${{ formatMoney(r.multa) }}</td>
                  <td class="text-right"><strong>${{ formatMoney(r.total) }}</strong></td>
                  <td>
                    <span :class="getTipoClass(r.tipo_calificacion_cod)">
                      {{ r.tipo_calificacion_desc }}
                    </span>
                  </td>
                  <td>{{ r.usuario_calificacion }}</td>
                  <td>{{ formatDate(r.fecha_calificacion) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="empty-state">
            <font-awesome-icon icon="search" size="3x" />
            <p>No se encontraron calificaciones</p>
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
const OP = 'RECAUDADORA_SFRM_CALIFICACIONQR'

const { loading, execute } = useApi()

const formData = ref({
  cuenta: '',
  folio: ''
})

const rows = ref([])
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

// Validación del formulario
const isFormValid = computed(() => {
  return formData.value.cuenta || formData.value.folio
})

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Formatear moneda
function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Clase CSS según tipo de calificación
function getTipoClass(tipo) {
  if (tipo === 'M') return 'badge badge-warning'
  if (tipo === 'O') return 'badge badge-info'
  return 'badge badge-secondary'
}

async function buscar() {
  hasSearched.value = true

  // IMPORTANTE: Enviar parámetros separados, no JSON
  const params = [
    { nombre: 'p_cuenta', tipo: 'string', valor: String(formData.value.cuenta || '') },
    { nombre: 'p_folio', tipo: 'string', valor: String(formData.value.folio || '') }
  ]

  try {
    const response = await execute(OP, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta
    let arr = []
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
    currentPage.value = 1
  } catch (e) {
    console.error('Error al buscar calificaciones:', e)
    rows.value = []
  }
}

function limpiar() {
  formData.value = {
    cuenta: '',
    folio: ''
  }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
}
</script>

<style scoped>
.form-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.municipal-form-control {
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  font-size: 1rem;
  transition: border-color 0.15s ease-in-out;
}

.municipal-form-control:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.button-group {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.text-right {
  text-align: right;
}

.badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.badge-warning {
  background-color: #ffc107;
  color: #000;
}

.badge-info {
  background-color: #17a2b8;
  color: #fff;
}

.badge-secondary {
  background-color: #6c757d;
  color: #fff;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #6c757d;
}

.empty-state svg {
  color: #dee2e6;
  margin-bottom: 1rem;
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

.btn-municipal-primary {
  padding: 0.5rem 1rem;
  border: 1px solid #007bff;
  border-radius: 0.25rem;
  background-color: #007bff;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-primary:hover:not(:disabled) {
  background-color: #0056b3;
  border-color: #0056b3;
}

.btn-municipal-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-municipal-secondary {
  padding: 0.5rem 1rem;
  border: 1px solid #6c757d;
  border-radius: 0.25rem;
  background-color: #6c757d;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #5a6268;
  border-color: #545b62;
}

.btn-municipal-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }

  .button-group {
    flex-direction: column;
  }
}
</style>

VUE;

file_put_contents($file, $newContent);

echo "✅ Archivo actualizado exitosamente\n\n";

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║         🎉 CALIFICACION QR ACTUALIZADO 🎉                  ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
echo "\n";
echo "📋 CAMBIOS APLICADOS:\n";
echo "   ✅ Parámetros separados (p_cuenta, p_folio) en lugar de JSON\n";
echo "   ✅ Paginación de 10 en 10 implementada\n";
echo "   ✅ Tabla HTML con 10 columnas\n";
echo "   ✅ Procesamiento correcto de respuesta eResponse.data.result\n";
echo "   ✅ Formateo de montos con decimales y comas\n";
echo "   ✅ Formateo de fechas con hora\n";
echo "   ✅ Badges de tipo de calificación:\n";
echo "       • M (Manual/Modificada): AMARILLO\n";
echo "       • O (Ordinaria): AZUL\n";
echo "   ✅ ID Multa en negritas\n";
echo "   ✅ Total en negritas\n";
echo "   ✅ Montos alineados a la derecha\n";
echo "   ✅ Estado vacío cuando no hay resultados\n";
echo "   ✅ Controles de paginación\n";
echo "\n";
echo "🎯 EJEMPLOS PARA PROBAR:\n";
echo "   1. Cuenta: 415267 → Calificación \$3,500.00 (Manual)\n";
echo "   2. Cuenta: 415266 → Calificación \$6,000.00 (Manual)\n";
echo "   3. Folio: 7048 → Encontrará la multa 415267\n";
echo "   4. Sin filtros → Error (requiere al menos un campo)\n";
echo "\n";
echo "🚀 Ahora recarga la página y prueba el módulo\n";
echo "\n";
