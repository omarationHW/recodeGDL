<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="file-invoice-dollar" />
        Reporte de Cuentas por Cobrar
      </h1>
      <DocumentationModal
        title="Ayuda - Cuentas por Cobrar"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Parámetros del Reporte
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="municipal-form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="municipal-form-control">
              <option value="">-- Todos los Cementerios --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label required">Año de Referencia</label>
            <input v-model.number="filtros.anio" type="number" class="municipal-form-control" :min="2000" :max="2100" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="generarReporte" class="btn-municipal-primary">
            <font-awesome-icon icon="file-pdf" />
            Generar Reporte
          </button>
          <button @click="exportarExcel" class="btn-municipal-success" v-if="cuentas.length > 0">
            <font-awesome-icon icon="file-excel" />
            Exportar a Excel
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="cuentas.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Cuentas por Cobrar ({{ cuentas.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
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
      <font-awesome-icon icon="check-circle" />
      No hay cuentas por cobrar en el período especificado
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_a_Cobrar'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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
    const params = [
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio || null,
        tipo: 'string'
      },
      {
        nombre: 'p_anio',
        valor: filtros.anio,
        tipo: 'integer'
      }
    ]

    const response = await execute('sp_cem_reporte_cuentas_cobrar', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    cuentas.value = response.result || []
    busquedaRealizada.value = true

    if (cuentas.value.length > 0) {
      toast.success(`Se encontraron ${cuentas.value.length} cuenta(s) por cobrar`)
    } else {
      toast.success('No hay cuentas por cobrar')
    }
  } catch (error) {
    toast.error('Error al generar reporte')
  }
}

const exportarExcel = () => {
  toast.info('Funcionalidad de exportación en desarrollo')
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = response.result || []
  } catch (error) {
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
/* Estilos únicos de resalte de adeudos y resumen - Justificado mantener scoped */
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
