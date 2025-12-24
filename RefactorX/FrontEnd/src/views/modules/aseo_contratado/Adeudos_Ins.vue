<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>Insertar Adeudos</h1>
        <p>Aseo Contratado - Inserción manual de adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="edit" /> Datos del Adeudo</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" />
            Complete el formulario para insertar un adeudo manual. Los campos marcados con * son obligatorios.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <div class="input-group">
                <input type="number" v-model="formData.num_contrato" class="municipal-form-control"
                  placeholder="Número de contrato" @blur="buscarContrato" required />
                <button class="btn-municipal-secondary" @click="abrirBuscador" type="button">
                  <font-awesome-icon icon="search" />
                </button>
              </div>
            </div>
            <div class="form-group" v-if="contratoInfo">
              <label class="municipal-form-label">Empresa</label>
              <input type="text" :value="contratoInfo.nom_emp" class="municipal-form-control" readonly />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Periodo (Mes/Año)</label>
              <input type="month" v-model="formData.periodo" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Operación</label>
              <select v-model="formData.cve_operacion" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option value="C">Cuota Normal</option>
                <option value="R">Recargo</option>
                <option value="M">Multa</option>
                <option value="G">Gastos de Ejecución</option>
                <option value="A">Actualización</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Importe</label>
              <div class="input-group">
                <span class="input-group-text">$</span>
                <input type="number" v-model="formData.importe" class="municipal-form-control"
                  placeholder="0.00" step="0.01" min="0" required />
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Excedencias</label>
              <input type="number" v-model="formData.exedencias" class="municipal-form-control"
                placeholder="0" min="0" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Observaciones</label>
              <textarea v-model="formData.observaciones" class="municipal-form-control"
                rows="3" placeholder="Observaciones adicionales (opcional)"></textarea>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="insertarAdeudo" :disabled="loading || !isFormValid">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              {{ loading ? 'Guardando...' : 'Insertar Adeudo' }}
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario" :disabled="loading">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Historial de adeudos insertados -->
      <div v-if="historial.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="history" /> Adeudos Insertados (Sesión Actual)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Contrato</th>
                  <th>Periodo</th>
                  <th>Tipo</th>
                  <th class="text-right">Importe</th>
                  <th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in historial" :key="item.folio">
                  <td><strong>{{ item.folio }}</strong></td>
                  <td>{{ item.num_contrato }}</td>
                  <td>{{ item.periodo }}</td>
                  <td>{{ getTipoOperacion(item.cve_operacion) }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe) }}</td>
                  <td>{{ formatDateTime(item.fecha) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Insertar Adeudos">
      <h3>Inserción Manual de Adeudos</h3>
      <p>Este módulo permite insertar adeudos de forma manual para casos especiales.</p>
      <h4>Tipos de Operación:</h4>
      <ul>
        <li><strong>Cuota Normal (C):</strong> Adeudo por servicio regular</li>
        <li><strong>Recargo (R):</strong> Recargo moratorio por pago tardío</li>
        <li><strong>Multa (M):</strong> Multa por infracción</li>
        <li><strong>Gastos de Ejecución (G):</strong> Gastos administrativos</li>
        <li><strong>Actualización (A):</strong> Actualización por inflación</li>
      </ul>
      <h4>Notas Importantes:</h4>
      <ul>
        <li>Verifique que el contrato exista antes de insertar</li>
        <li>El importe debe ser mayor a cero</li>
        <li>El periodo debe estar en formato Mes/Año válido</li>
        <li>Se genera un folio automático para cada inserción</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const contratoInfo = ref(null)
const historial = ref([])

const formData = ref({
  num_contrato: null,
  periodo: '',
  cve_operacion: '',
  importe: null,
  exedencias: 0,
  observaciones: ''
})

const isFormValid = computed(() => {
  return formData.value.num_contrato &&
         formData.value.periodo &&
         formData.value.cve_operacion &&
         formData.value.importe > 0
})

const buscarContrato = async () => {
  if (!formData.value.num_contrato) return

  loading.value = true
  try {
    const response = await execute('SP_ASEO_ADEUDOS_BUSCAR_CONTRATO', 'aseo_contratado', {
      p_num_contrato: formData.value.num_contrato,
      p_num_empresa: null,
      p_nombre_empresa: null
    })
    if (response && response.data && response.data.length > 0) {
      contratoInfo.value = response.data[0]
    } else {
      showToast('Contrato no encontrado', 'warning')
      contratoInfo.value = null
    }
  } catch (error) {
    console.error('Error:', error)
    contratoInfo.value = null
  } finally {
    loading.value = false
  }
}

const insertarAdeudo = async () => {
  if (!isFormValid.value) return

  loading.value = true
  try {
    // Convertir periodo a fecha (primer día del mes)
    const [year, month] = formData.value.periodo.split('-')
    const fechaPago = `${year}-${month}-01`

    const response = await execute('SP_ASEO_ADEUDOS_INSERTAR', 'aseo_contratado', {
      p_control_contrato: contratoInfo.value.control_contrato,
      p_aso_mes_pago: fechaPago,
      p_cve_operacion: formData.value.cve_operacion,
      p_importe: formData.value.importe,
      p_exedencias: formData.value.exedencias || 0,
      p_usuario_id: 1
    })

    if (response && response.data && response.data[0]) {
      const result = response.data[0]
      if (result.success) {
        showToast('Adeudo insertado exitosamente', 'success')

        // Agregar al historial
        historial.value.unshift({
          folio: result.folio_rcbo,
          num_contrato: formData.value.num_contrato,
          periodo: formData.value.periodo,
          cve_operacion: formData.value.cve_operacion,
          importe: formData.value.importe,
          fecha: new Date()
        })

        limpiarFormulario()
      } else {
        showToast(result.message || 'Error al insertar adeudo', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al insertar el adeudo', 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFormulario = () => {
  formData.value = {
    num_contrato: null,
    periodo: '',
    cve_operacion: '',
    importe: null,
    exedencias: 0,
    observaciones: ''
  }
  contratoInfo.value = null
}

const abrirBuscador = () => {
  showToast('Abrir buscador de contratos', 'info')
}

const getTipoOperacion = (cve) => {
  const tipos = {
    C: 'Cuota Normal',
    R: 'Recargo',
    M: 'Multa',
    G: 'Gastos',
    A: 'Actualización'
  }
  return tipos[cve] || cve
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDateTime = (date) => {
  return new Date(date).toLocaleString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>
