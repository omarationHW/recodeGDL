<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calculator" />
      </div>
      <div class="module-view-info">
        <h1>Prueba Cálculos</h1>
        <p>Cálculo de multas, recargos y descuentos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de parámetros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Importe Base</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="params.p_importe_base"
                placeholder="1000"
                step="0.01"
                min="0"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Meses de Mora</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="params.p_meses_mora"
                placeholder="0"
                min="0"
                max="60"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">% Descuento</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="params.p_porc_descuento"
                placeholder="0"
                step="0.01"
                min="0"
                max="100"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="calcular"
            >
              <font-awesome-icon icon="calculator" v-if="!loading" />
              <span v-if="loading">Calculando...</span>
              <span v-else>Calcular</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Ejemplos rápidos -->
      <div class="municipal-card" v-if="!resultado">
        <div class="municipal-card-header">
          <h5>📝 Ejemplos Rápidos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="ejemplos-grid">
            <button class="ejemplo-btn" @click="cargarEjemplo(1)">
              <strong>Ejemplo 1</strong>
              <small>$1,000 sin mora</small>
            </button>
            <button class="ejemplo-btn" @click="cargarEjemplo(2)">
              <strong>Ejemplo 2</strong>
              <small>$5,000 con 6 meses</small>
            </button>
            <button class="ejemplo-btn" @click="cargarEjemplo(3)">
              <strong>Ejemplo 3</strong>
              <small>$10,000 + descuento 20%</small>
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>💰 Resultados del Cálculo</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table" style="width: 100%; border: 1px solid #ddd;">
              <thead class="municipal-table-header" style="background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);">
                <tr>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Concepto</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">Descripción</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold; text-align: right;">Valor</th>
                  <th style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold; text-align: right;">%</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(row, idx) in resultado"
                  :key="idx"
                  :class="{ 'row-total': row.concepto && row.concepto.includes('TOTAL'), 'row-hover': true }"
                  style="border-bottom: 1px solid #ddd;"
                >
                  <td style="padding: 8px; border: 1px solid #ddd; font-weight: 600;">
                    {{ row.concepto }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd;">
                    {{ row.descripcion }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd; text-align: right; font-weight: 600;">
                    {{ formatCurrency(row.valor) }}
                  </td>
                  <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">
                    {{ row.porcentaje > 0 ? row.porcentaje + '%' : '-' }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'pruebacalcas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Prueba Cálculos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'pruebacalcas'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Prueba Cálculos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_PRUEBACALCAS'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const params = ref({
  p_importe_base: 1000,
  p_meses_mora: 0,
  p_porc_descuento: 0
})

const resultado = ref(null)
const error = ref(null)

function cargarEjemplo(num) {
  switch(num) {
    case 1:
      params.value = {
        p_importe_base: 1000,
        p_meses_mora: 0,
        p_porc_descuento: 0
      }
      break
    case 2:
      params.value = {
        p_importe_base: 5000,
        p_meses_mora: 6,
        p_porc_descuento: 0
      }
      break
    case 3:
      params.value = {
        p_importe_base: 10000,
        p_meses_mora: 12,
        p_porc_descuento: 20
      }
      break
  }
  calcular()
}

async function calcular() {
  error.value = null
  resultado.value = null

  try {
    showLoading('Consultando...', 'Por favor espere')
    console.log('🔍 Ejecutando SP:', OP)
    console.log('🔍 Parámetros:', params.value)

    const data = await execute(OP, BASE_DB, params.value, '', null, SCHEMA)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    resultado.value = arr

  } catch (e) {
    error.value = e.message || 'Error al ejecutar el cálculo'
    console.error('❌ Error:', e)
  } finally {
    hideLoading()
  }
}

function limpiar() {
  params.value = {
    p_importe_base: 1000,
    p_meses_mora: 0,
    p_porc_descuento: 0
  }
  resultado.value = null
  error.value = null
}

function formatCurrency(value) {
  if (value === null || value === undefined) return '-'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Cargar ejemplo 1 al inicio
cargarEjemplo(1)
</script>

