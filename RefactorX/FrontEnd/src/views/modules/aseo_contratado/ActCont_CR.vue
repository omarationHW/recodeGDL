<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="sync-alt" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Masiva de Contratos</h1>
        <p>Aseo Contratado - Cambio de recargos y actualizaciones masivas</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Selección de Operación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="tasks" /> Tipo de Actualización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-group">
            <label class="municipal-form-label required">Operación a Realizar</label>
            <select v-model="tipoOperacion" class="municipal-form-control" @change="cambiarOperacion">
              <option value="">Seleccione una operación...</option>
              <option value="CAMBIO_RECARGO">Cambio Masivo de Recargos</option>
              <option value="ACTUALIZAR_PERIODO">Actualizar Periodo de Contratos</option>
              <option value="CAMBIAR_UNIDADES">Cambiar Unidades de Recolección</option>
              <option value="ACTIVAR_CONTRATOS">Activar Contratos (Nuevo a Vigente)</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Cambio de Recargos -->
      <div v-if="tipoOperacion === 'CAMBIO_RECARGO'" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="percent" /> Cambio Masivo de Recargos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Advertencia:</strong> Esta operación actualizará los porcentajes de recargos para todos los contratos seleccionados.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="T">Todos</option>
                <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo" :value="tipo.tipo_aseo">
                  {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status de Contratos</label>
              <select v-model="filtros.status" class="municipal-form-control">
                <option value="V">Solo Vigentes</option>
                <option value="N">Solo Nuevos</option>
                <option value="T">Todos (Vigentes + Nuevos)</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Ejercicio Fiscal</label>
              <input type="number" v-model="parametros.ejercicio" class="municipal-form-control"
                :min="currentYear - 1" :max="currentYear + 1" :placeholder="currentYear" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Mes Inicial</label>
              <select v-model="parametros.mes_inicial" class="municipal-form-control" required>
                <option v-for="mes in 12" :key="mes" :value="mes">
                  {{ getNombreMes(mes) }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Mes Final</label>
              <select v-model="parametros.mes_final" class="municipal-form-control" required>
                <option v-for="mes in 12" :key="mes" :value="mes">
                  {{ getNombreMes(mes) }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'eye'" :spin="loading" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon :icon="loading ? 'spinner' : 'sync-alt'" :spin="loading" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Actualizar Periodo -->
      <div v-if="tipoOperacion === 'ACTUALIZAR_PERIODO'" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Actualizar Periodo de Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" />
            Esta operación permite extender o modificar el periodo de vigencia de contratos.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Nueva Fecha de Inicio</label>
              <input type="month" v-model="parametros.nuevo_inicio" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Nueva Fecha de Fin</label>
              <input type="month" v-model="parametros.nuevo_fin" class="municipal-form-control" required />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'eye'" :spin="loading" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon :icon="loading ? 'spinner' : 'sync-alt'" :spin="loading" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Cambiar Unidades -->
      <div v-if="tipoOperacion === 'CAMBIAR_UNIDADES'" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="truck" /> Cambiar Unidades de Recolección</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" />
            Cambie las unidades de recolección de múltiples contratos simultáneamente.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Unidad de Origen</label>
              <select v-model="parametros.unidad_origen" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="unidad in unidadesRecoleccion" :key="unidad.cve_recolec" :value="unidad.cve_recolec">
                  {{ unidad.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Unidad de Destino</label>
              <select v-model="parametros.unidad_destino" class="municipal-form-control" required>
                <option value="">Seleccione...</option>
                <option v-for="unidad in unidadesRecoleccion" :key="unidad.cve_recolec" :value="unidad.cve_recolec">
                  {{ unidad.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'eye'" :spin="loading" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon :icon="loading ? 'spinner' : 'sync-alt'" :spin="loading" /> Ejecutar Actualización
            </button>
          </div>
        </div>
      </div>

      <!-- Activar Contratos -->
      <div v-if="tipoOperacion === 'ACTIVAR_CONTRATOS'" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle" /> Activar Contratos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <font-awesome-icon icon="info-circle" />
            Cambie el status de contratos de "Nuevo" a "Vigente" de forma masiva.
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="previsualizarContratos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'eye'" :spin="loading" /> Vista Previa
            </button>
            <button class="btn-municipal-primary" @click="ejecutarActualizacion"
              :disabled="loading || contratosAfectados.length === 0">
              <font-awesome-icon :icon="loading ? 'spinner' : 'check-circle'" :spin="loading" /> Activar Contratos
            </button>
          </div>
        </div>
      </div>

      <!-- Vista Previa de Contratos Afectados -->
      <div v-if="contratosAfectados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Contratos que Serán Afectados ({{ contratosAfectados.length }})</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Tipo Aseo</th>
                  <th>Unidades</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratosAfectados" :key="contrato.control_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.nombre_empresa }}</td>
                  <td>{{ contrato.tipo_aseo_descripcion }}</td>
                  <td>{{ contrato.cantidad_recoleccion }} - {{ contrato.unidad_recoleccion }}</td>
                  <td>
                    <span :class="['badge', getStatusClass(contrato.status_contrato)]">
                      {{ getStatusLabel(contrato.status_contrato) }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Resultado de la Operación -->
      <div v-if="resultado" class="municipal-card mt-3">
        <div class="municipal-card-header" :class="resultado.success ? 'bg-success' : 'bg-danger'">
          <h5 class="text-white">
            <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" />
            {{ resultado.success ? 'Operación Completada' : 'Error en Operación' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <p><strong>{{ resultado.message }}</strong></p>
          <div v-if="resultado.success" class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">Contratos Procesados</label>
              <p class="detail-value">{{ resultado.contratos_procesados }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Actualizaciones Exitosas</label>
              <p class="detail-value">{{ resultado.actualizaciones_exitosas }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Actualización Masiva">
      <h3>Actualización Masiva de Contratos</h3>
      <p>Este módulo permite realizar operaciones masivas sobre múltiples contratos simultáneamente.</p>

      <h4>Operaciones Disponibles:</h4>

      <h5>1. Cambio Masivo de Recargos</h5>
      <p>Actualiza los porcentajes de recargos moratorios para todos los contratos del ejercicio seleccionado.</p>
      <ul>
        <li>Seleccione el ejercicio fiscal</li>
        <li>Defina el periodo (mes inicial y final)</li>
        <li>Filtre por tipo de aseo y status</li>
      </ul>

      <h5>2. Actualizar Periodo de Contratos</h5>
      <p>Modifica el periodo de vigencia de contratos masivamente.</p>
      <ul>
        <li>Útil para extensiones de contrato</li>
        <li>Especifique nuevas fechas de inicio y fin</li>
      </ul>

      <h5>3. Cambiar Unidades de Recolección</h5>
      <p>Cambia el tipo de unidad de recolección de múltiples contratos.</p>
      <ul>
        <li>Seleccione la unidad de origen</li>
        <li>Seleccione la unidad de destino</li>
      </ul>

      <h5>4. Activar Contratos</h5>
      <p>Cambia el status de contratos de "Nuevo" a "Vigente" masivamente.</p>
      <ul>
        <li>Útil al inicio de un periodo</li>
        <li>Solo afecta contratos en status "Nuevo"</li>
      </ul>

      <h4>Procedimiento General:</h4>
      <ol>
        <li>Seleccione el tipo de operación</li>
        <li>Configure los parámetros necesarios</li>
        <li>Use "Vista Previa" para ver los contratos afectados</li>
        <li>Revise la lista de contratos</li>
        <li>Ejecute la actualización</li>
      </ol>

      <h4>Precauciones:</h4>
      <ul>
        <li>Siempre use la vista previa antes de ejecutar</li>
        <li>Estas operaciones afectan múltiples contratos</li>
        <li>No son reversibles automáticamente</li>
        <li>Se recomienda hacer respaldo antes de operaciones masivas</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const tipoOperacion = ref('')
const tiposAseo = ref([])
const unidadesRecoleccion = ref([])
const contratosAfectados = ref([])
const resultado = ref(null)
const currentYear = new Date().getFullYear()

const filtros = ref({
  tipo_aseo: 'T',
  status: 'V'
})

const parametros = ref({
  ejercicio: currentYear,
  mes_inicial: 1,
  mes_final: 12,
  nuevo_inicio: '',
  nuevo_fin: '',
  unidad_origen: '',
  unidad_destino: ''
})

const cambiarOperacion = () => {
  contratosAfectados.value = []
  resultado.value = null
}

const previsualizarContratos = async () => {
  loading.value = true

  try {
    let parTipo = filtros.value.tipo_aseo
    let parVigencia = filtros.value.status

    // Ajustar vigencia según el tipo de operación
    if (tipoOperacion.value === 'ACTIVAR_CONTRATOS') {
      parVigencia = 'N' // Solo contratos nuevos
    }

    const response = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: parTipo,
      parVigencia: parVigencia
    })

    if (response && response.data) {
      contratosAfectados.value = response.data

      // Filtros adicionales según tipo de operación
      if (tipoOperacion.value === 'CAMBIAR_UNIDADES' && parametros.value.unidad_origen) {
        contratosAfectados.value = contratosAfectados.value.filter(
          c => c.cve_recoleccion === parametros.value.unidad_origen
        )
      }

      if (contratosAfectados.value.length === 0) {
        showToast('No se encontraron contratos para los criterios seleccionados', 'info')
      } else {
        showToast(`Se encontraron ${contratosAfectados.value.length} contratos`, 'success')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al cargar contratos', 'error')
  } finally {
    loading.value = false
  }
}

const ejecutarActualizacion = async () => {
  if (contratosAfectados.value.length === 0) {
    showToast('No hay contratos para actualizar', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Ejecutar Actualización Masiva?',
    html: `<p>Se actualizarán <strong>${contratosAfectados.value.length} contratos</strong></p>
           <p class="text-warning">Esta operación no es reversible automáticamente</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, ejecutar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745'
  })

  if (!confirmResult.isConfirmed) return

  loading.value = true

  try {
    // Nota: Estos SPs deben ser creados según el tipo de operación
    let spName = ''
    let params = {}

    switch (tipoOperacion.value) {
      case 'CAMBIO_RECARGO':
        spName = 'SP_ASEO_CONTRATOS_CAMBIO_RECARGOS'
        params = {
          p_tipo_aseo: filtros.value.tipo_aseo,
          p_status: filtros.value.status,
          p_ejercicio: parametros.value.ejercicio,
          p_mes_inicial: parametros.value.mes_inicial,
          p_mes_final: parametros.value.mes_final,
          p_usuario_id: 1
        }
        break

      case 'ACTUALIZAR_PERIODO':
        spName = 'SP_ASEO_CONTRATOS_ACTUALIZAR_PERIODO'
        params = {
          p_contratos: contratosAfectados.value.map(c => c.control_contrato),
          p_nuevo_inicio: `${parametros.value.nuevo_inicio}-01`,
          p_nuevo_fin: `${parametros.value.nuevo_fin}-01`,
          p_usuario_id: 1
        }
        break

      case 'CAMBIAR_UNIDADES':
        spName = 'SP_ASEO_CONTRATOS_CAMBIAR_UNIDADES'
        params = {
          p_unidad_origen: parametros.value.unidad_origen,
          p_unidad_destino: parametros.value.unidad_destino,
          p_usuario_id: 1
        }
        break

      case 'ACTIVAR_CONTRATOS':
        spName = 'SP_ASEO_CONTRATOS_ACTIVAR'
        params = {
          p_usuario_id: 1
        }
        break
    }

    const response = await execute(spName, 'aseo_contratado', params)

    if (response && response.data && response.data[0]) {
      resultado.value = response.data[0]

      if (resultado.value.success) {
        showToast('Actualización completada exitosamente', 'success')
        contratosAfectados.value = []
      } else {
        showToast(resultado.value.message, 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al ejecutar la actualización', 'error')
    resultado.value = {
      success: false,
      message: error.message || 'Error desconocido',
      contratos_procesados: 0,
      actualizaciones_exitosas: 0
    }
  } finally {
    loading.value = false
  }
}

const getNombreMes = (mes) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[mes - 1]
}

const getStatusLabel = (status) => {
  const labels = {
    V: 'Vigente',
    N: 'Nuevo',
    B: 'Baja',
    C: 'Cancelado'
  }
  return labels[status] || status
}

const getStatusClass = (status) => {
  const classes = {
    V: 'badge-success',
    N: 'badge-info',
    B: 'badge-warning',
    C: 'badge-danger'
  }
  return classes[status] || 'badge-secondary'
}

const cargarTiposAseo = async () => {
  try {
    const response = await execute('SP_ASEO_TIPOS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      tiposAseo.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar tipos de aseo:', error)
  }
}

const cargarUnidadesRecoleccion = async () => {
  try {
    const response = await execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      unidadesRecoleccion.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar unidades de recolección:', error)
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  cargarTiposAseo()
  cargarUnidadesRecoleccion()
})
</script>

