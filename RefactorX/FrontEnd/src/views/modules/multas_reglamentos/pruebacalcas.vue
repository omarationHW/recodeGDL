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

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_PRUEBACALCAS'
const { loading, execute } = useApi()

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
    console.log('🔍 Ejecutando SP:', OP)
    console.log('🔍 Parámetros:', params.value)

    const data = await execute(OP, BASE_DB, params.value)

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

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
}

.municipal-form-control {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.ejemplos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.ejemplo-btn {
  padding: 15px;
  border: 2px solid #ea8215;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.ejemplo-btn:hover {
  background: #fff5ed;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(234, 130, 21, 0.2);
}

.ejemplo-btn strong {
  color: #ea8215;
  font-size: 16px;
}

.ejemplo-btn small {
  color: #666;
  font-size: 13px;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.row-total {
  background-color: #fff5ed;
  font-weight: bold;
}

.row-total td {
  color: #ea8215;
  font-size: 16px;
}

.table-responsive {
  overflow-x: auto;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}
</style>
