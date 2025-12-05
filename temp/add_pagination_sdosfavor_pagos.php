<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/SdosFavor_Pagos.vue';

echo "📋 Agregando paginación a SdosFavor_Pagos.vue...\n\n";

$newContent = <<<'VUE'
<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="receipt" /></div>
      <div class="module-view-info">
        <h1>Pagos de Saldos a Favor</h1>
        <p>Consulta de pagos</p>
      </div>
    </div>

    <div class="module-view-content">
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
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Pagos ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Ejercicio</th>
                  <th>Imp. Inconform</th>
                  <th>Imp. Pago</th>
                  <th>Saldo Favor</th>
                  <th>Fecha Pago</th>
                  <th>Solicitante</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_pago_favor" class="row-hover">
                  <td>{{ r.id_pago_favor }}</td>
                  <td>{{ r.cvecuenta }}</td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>${{ formatMoney(r.imp_inconform) }}</td>
                  <td>${{ formatMoney(r.imp_pago) }}</td>
                  <td>
                    <span :class="getSaldoClass(r.saldo_favor)">
                      ${{ formatMoney(r.saldo_favor) }}
                    </span>
                  </td>
                  <td>{{ r.fecha_pago || 'N/A' }}</td>
                  <td>{{ r.solicitante || 'N/A' }}</td>
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
const OP_LIST = 'RECAUDADORA_SDOSFAVOR_PAGOS'
const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

function getSaldoClass(saldo) {
  const s = parseFloat(saldo || 0)
  if (s > 0) return 'saldo-pendiente'
  return 'saldo-liquidado'
}

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
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
    console.error('Error cargando pagos:', e)
    rows.value = []
  }
}
</script>

<style scoped>
.saldo-pendiente {
  color: #28a745;
  font-weight: 600;
}

.saldo-liquidado {
  color: #6c757d;
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
echo "   ✅ Saldo a favor en VERDE si es pendiente\n";
echo "   ✅ Saldo a favor en GRIS si está liquidado\n";
echo "   ✅ Placeholder en input de cuenta\n";
echo "\n";
echo "🎯 FUNCIONALIDADES:\n";
echo "   • Muestra 10 registros por página\n";
echo "   • Navegación entre páginas\n";
echo "   • Contador \"Mostrando X - Y de Z registros\"\n";
echo "   • Indicador \"Página X de Y\"\n";
echo "   • Saldos pendientes resaltados en VERDE\n";
echo "   • Saldos liquidados en GRIS\n";
echo "\n";
echo "🚀 Ahora recarga la página y prueba el módulo\n";
echo "\n";
