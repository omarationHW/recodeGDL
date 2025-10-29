<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-file-invoice-dollar"></i>
        Reporte de Cuentas por Cobrar
      </h1>
      <DocumentationModal
        title="Ayuda - Cuentas por Cobrar"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Parámetros del Reporte
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="form-control">
              <option value="">-- Todos los Cementerios --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label required">Año de Referencia</label>
            <input v-model.number="filtros.anio" type="number" class="form-control" :min="2000" :max="2100" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="generarReporte" class="btn-municipal-primary">
            <i class="fas fa-file-pdf"></i>
            Generar Reporte
          </button>
          <button @click="exportarExcel" class="btn-municipal-success" v-if="cuentas.length > 0">
            <i class="fas fa-file-excel"></i>
            Exportar a Excel
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="cuentas.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Cuentas por Cobrar ({{ cuentas.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Folio</th>
                <th>Cementerio</th>
                <th>Titular</th>
                <th>Domicilio</th>
                <th>Año Pagado</th>
                <th>Años de Adeudo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="cuenta in cuentas" :key="cuenta.control_rcm" :class="getRowClass(cuenta.anios_adeudo)">
                <td>{{ cuenta.control_rcm }}</td>
                <td>{{ cuenta.cementerio }}</td>
                <td>{{ cuenta.nombre }}</td>
                <td>{{ cuenta.domicilio }}</td>
                <td>{{ cuenta.axo_pagado }}</td>
                <td><strong>{{ cuenta.anios_adeudo }}</strong></td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Resumen -->
        <div class="resumen-box mt-3">
          <h5>Resumen</h5>
          <div class="resumen-grid">
            <div class="resumen-item">
              <span class="resumen-label">Total de Cuentas:</span>
              <span class="resumen-value">{{ cuentas.length }}</span>
            </div>
            <div class="resumen-item">
              <span class="resumen-label">Adeudo 1 año:</span>
              <span class="resumen-value text-warning">{{ contarPorAnios(1) }}</span>
            </div>
            <div class="resumen-item">
              <span class="resumen-label">Adeudo 2-3 años:</span>
              <span class="resumen-value text-danger">{{ contarPorAnios(2, 3) }}</span>
            </div>
            <div class="resumen-item">
              <span class="resumen-label">Adeudo 4+ años:</span>
              <span class="resumen-value text-danger-dark">{{ contarPorAnios(4, 999) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-success">
      <i class="fas fa-check-circle"></i>
      No hay cuentas por cobrar en el período especificado
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const filtros = reactive({
  cementerio: '',
  anio: new Date().getFullYear()
})

const cuentas = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Reporte de Cuentas por Cobrar',
    content: `
      <p>Genera un reporte detallado de todos los folios con pagos atrasados.</p>
      <h4>Filtros:</h4>
      <ul>
        <li><strong>Cementerio:</strong> Filtra por cementerio específico o todos</li>
        <li><strong>Año de Referencia:</strong> Año contra el cual se comparan los pagos</li>
      </ul>
      <h4>Clasificación de Adeudos:</h4>
      <ul>
        <li><strong>1 año:</strong> Amarillo - Adeudo reciente</li>
        <li><strong>2-3 años:</strong> Naranja - Adeudo medio</li>
        <li><strong>4+ años:</strong> Rojo - Adeudo crítico</li>
      </ul>
    `
  }
]

const generarReporte = async () => {
  if (!filtros.anio) {
    toast.warning('Debe especificar el año de referencia')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_REPORTE_CUENTAS_COBRAR', {
      p_cementerio: filtros.cementerio || null,
      p_anio: filtros.anio
    })

    cuentas.value = response.data || []
    busquedaRealizada.value = true

    if (cuentas.value.length > 0) {
      toast.success(`Se encontraron ${cuentas.value.length} cuenta(s) por cobrar`)
    } else {
      toast.success('No hay cuentas por cobrar')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    toast.error('Error al generar reporte')
  }
}

const exportarExcel = () => {
  toast.info('Funcionalidad de exportación en desarrollo')
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const getRowClass = (anios) => {
  if (anios === 1) return 'row-warning'
  if (anios >= 2 && anios <= 3) return 'row-danger'
  if (anios >= 4) return 'row-danger-dark'
  return ''
}

const contarPorAnios = (min, max = min) => {
  return cuentas.value.filter(c => c.anios_adeudo >= min && c.anios_adeudo <= max).length
}

onMounted(() => {
  cargarCementerios()
})
</script>

<style scoped>
.row-warning {
  background-color: #fff3cd;
}

.row-danger {
  background-color: #f8d7da;
}

.row-danger-dark {
  background-color: #f5c6cb;
  font-weight: bold;
}

.text-warning {
  color: var(--color-warning);
  font-weight: bold;
}

.text-danger {
  color: var(--color-danger);
  font-weight: bold;
}

.text-danger-dark {
  color: #a71d2a;
  font-weight: bold;
}

.resumen-box {
  padding: 1.5rem;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  border-left: 4px solid var(--color-primary);
}

.resumen-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-top: 1rem;
}

.resumen-item {
  display: flex;
  justify-content: space-between;
  padding: 0.75rem;
  background-color: white;
  border-radius: 0.25rem;
}

.resumen-label {
  font-weight: 500;
  color: var(--color-text-secondary);
}

.resumen-value {
  font-weight: bold;
  font-size: 1.25rem;
  color: var(--color-primary);
}
</style>
