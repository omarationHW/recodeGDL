<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="copy" />
      </div>
      <div class="module-view-info">
        <h1>Registros Duplicados</h1>
        <p>Cementerios - Gestión de registros duplicados y traslados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de duplicados -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="search" />
          Buscar Duplicados
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-two">
            <div class="form-group">
              <label class="municipal-form-label">Nombre del Titular</label>
              <input
                v-model="busqueda.nombre"
                type="text"
                class="municipal-form-control"
                placeholder="Ingrese nombre a buscar"
                @keyup.enter="buscarDuplicados"
              />
            </div>
            <div class="form-group align-end">
              <button @click="buscarDuplicados" class="btn-municipal-primary">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="duplicados.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="copy" size="3x" />
        </div>
        <h4>Registros Duplicados</h4>
        <p>Ingrese el nombre del titular para buscar duplicados en el sistema</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="duplicados.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron duplicados con el nombre especificado</p>
      </div>

      <!-- Grid de duplicados encontrados -->
      <div v-if="duplicados.length > 0" class="municipal-card mb-3">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Duplicados Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ duplicados.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th>Ubicación Actual</th>
                  <th>Fecha Ingreso</th>
                  <th>Años Pago</th>
                  <th>Importe</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="dup in duplicados"
                  :key="dup.control_id"
                  @click="selectedRow = dup"
                  :class="{ 'table-row-selected': selectedRow === dup }"
                  class="row-hover"
                >
                  <td>{{ dup.nombre }}</td>
                  <td>{{ formatearDomicilio(dup) }}</td>
                  <td>{{ formatearUbicacion(dup) }}</td>
                  <td>{{ formatearFecha(dup.fecing) }}</td>
                  <td>{{ dup.axo_pago_desde }} - {{ dup.axo_pago_hasta }}</td>
                  <td>{{ formatearMoneda(dup.importe_anual) }}</td>
                  <td>
                    <button
                      @click.stop="seleccionarDuplicado(dup)"
                      class="btn-municipal-secondary btn-sm"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Formulario de traslado -->
      <div v-if="duplicadoSeleccionado" class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="exchange-alt" />
          Trasladar Duplicado: {{ duplicadoSeleccionado.nombre }}
        </div>
        <div class="municipal-card-body">
          <!-- Información del duplicado -->
          <div class="alert-info mb-3">
            <strong>Registro seleccionado:</strong><br>
            Ubicación actual: {{ formatearUbicacion(duplicadoSeleccionado) }}<br>
            Período: {{ duplicadoSeleccionado.axo_pago_desde }} - {{ duplicadoSeleccionado.axo_pago_hasta }}
            | Importe: {{ formatearMoneda(duplicadoSeleccionado.importe_anual) }}
          </div>

          <!-- Nueva ubicación -->
          <div class="info-section">
            <h3 class="section-title">Nueva Ubicación</h3>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Cementerio</label>
                <select v-model="nuevaUbicacion.cementerio" class="municipal-form-control">
                  <option value="">-- Seleccione --</option>
                  <option
                    v-for="cem in cementerios"
                    :key="cem.cementerio"
                    :value="cem.cementerio"
                  >
                    {{ cem.nombre }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="form-label required">Tipo de Ubicación</label>
                <div class="radio-group">
                  <label class="radio-option">
                    <input type="radio" v-model="nuevaUbicacion.tipo" value="F" />
                    <span>Fosa</span>
                  </label>
                  <label class="radio-option">
                    <input type="radio" v-model="nuevaUbicacion.tipo" value="U" />
                    <span>Urna</span>
                  </label>
                  <label class="radio-option">
                    <input type="radio" v-model="nuevaUbicacion.tipo" value="G" />
                    <span>Gaveta</span>
                  </label>
                </div>
              </div>
            </div>

            <div class="form-grid-four">
              <div class="form-group">
                <label class="form-label required">Clase</label>
                <input
                  v-model.number="nuevaUbicacion.clase"
                  type="number"
                  class="municipal-form-control"
                  min="1"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clase Alfa</label>
                <input
                  v-model="nuevaUbicacion.clase_alfa"
                  type="text"
                  class="municipal-form-control"
                  maxlength="2"
                />
              </div>
              <div class="form-group">
                <label class="form-label required">Sección</label>
                <input
                  v-model.number="nuevaUbicacion.seccion"
                  type="number"
                  class="municipal-form-control"
                  min="1"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección Alfa</label>
                <input
                  v-model="nuevaUbicacion.seccion_alfa"
                  type="text"
                  class="municipal-form-control"
                  maxlength="2"
                />
              </div>
            </div>

            <div class="form-grid-four">
              <div class="form-group">
                <label class="form-label required">Línea</label>
                <input
                  v-model.number="nuevaUbicacion.linea"
                  type="number"
                  class="municipal-form-control"
                  min="1"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Línea Alfa</label>
                <input
                  v-model="nuevaUbicacion.linea_alfa"
                  type="text"
                  class="municipal-form-control"
                  maxlength="2"
                />
              </div>
              <div class="form-group">
                <label class="form-label required">Fosa</label>
                <input
                  v-model.number="nuevaUbicacion.fosa"
                  type="number"
                  class="municipal-form-control"
                  min="1"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fosa Alfa</label>
                <input
                  v-model="nuevaUbicacion.fosa_alfa"
                  type="text"
                  class="municipal-form-control"
                  maxlength="4"
                />
              </div>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Observaciones</label>
              <textarea
                v-model="nuevaUbicacion.observaciones"
                class="municipal-form-control"
                rows="2"
                maxlength="255"
              ></textarea>
            </div>
          </div>

          <!-- Modo de operación -->
          <div class="info-section">
            <h3 class="section-title">Modo de Operación</h3>
            <div class="radio-group">
              <label class="radio-option">
                <input type="radio" v-model="operacion" value="1" />
                <span>Solo Pagos (Los datos ya existen en la ubicación)</span>
              </label>
              <label class="radio-option">
                <input type="radio" v-model="operacion" value="2" />
                <span>Todo (Crear datos y trasladar pagos)</span>
              </label>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="form-actions">
            <button @click="verificarYTrasladar" class="btn-municipal-primary">
              <font-awesome-icon icon="check" />
              Trasladar Duplicado
            </button>
            <button @click="cancelarSeleccion" class="btn-municipal-secondary">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Duplicados'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Registros Duplicados'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const busqueda = reactive({
  nombre: ''
})

const duplicados = ref([])
const duplicadoSeleccionado = ref(null)
const cementerios = ref([])
const operacion = ref('2')
const selectedRow = ref(null)
const hasSearched = ref(false)

const nuevaUbicacion = reactive({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: '',
  tipo: 'F',
  observaciones: ''
})

const buscarDuplicados = async () => {
  if (!busqueda.nombre.trim()) {
    showToast('warning', 'Ingrese un nombre para buscar')
    return
  }

  showLoading('Buscando duplicados...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const patron = `%${busqueda.nombre}%`
    const response = await execute(
      'sp_duplicados_buscar_por_nombre',
      'cementerio',
      [
        { nombre: 'p_nombre', valor: patron, tipo: 'string' }
      ],
      'cementerio',
      null,
      'public'
    )

    duplicados.value = response?.result || []
    duplicadoSeleccionado.value = null

    if (duplicados.value.length === 0) {
      showToast('info', 'No se encontraron duplicados')
    } else {
      showToast('success', `Se encontraron ${duplicados.value.length} duplicado(s)`)
    }
  } catch (error) {
    console.error('Error al buscar duplicados:', error)
    showToast('error', 'Error al buscar duplicados')
  } finally {
    hideLoading()
  }
}

const seleccionarDuplicado = (dup) => {
  duplicadoSeleccionado.value = dup
  // Prellenar con la ubicación actual como sugerencia
  nuevaUbicacion.cementerio = dup.cementerio
  nuevaUbicacion.clase = dup.clase
  nuevaUbicacion.clase_alfa = dup.clase_alfa || ''
  nuevaUbicacion.seccion = dup.seccion
  nuevaUbicacion.seccion_alfa = dup.seccion_alfa || ''
  nuevaUbicacion.linea = dup.linea
  nuevaUbicacion.linea_alfa = dup.linea_alfa || ''
  nuevaUbicacion.fosa = dup.fosa
  nuevaUbicacion.fosa_alfa = dup.fosa_alfa || ''
  nuevaUbicacion.observaciones = ''
}

const cancelarSeleccion = () => {
  duplicadoSeleccionado.value = null
  limpiarFormulario()
}

const limpiarFormulario = () => {
  nuevaUbicacion.cementerio = ''
  nuevaUbicacion.clase = null
  nuevaUbicacion.clase_alfa = ''
  nuevaUbicacion.seccion = null
  nuevaUbicacion.seccion_alfa = ''
  nuevaUbicacion.linea = null
  nuevaUbicacion.linea_alfa = ''
  nuevaUbicacion.fosa = null
  nuevaUbicacion.fosa_alfa = ''
  nuevaUbicacion.tipo = 'F'
  nuevaUbicacion.observaciones = ''
  operacion.value = '2'
}

const verificarYTrasladar = async () => {
  // Validaciones
  if (!nuevaUbicacion.cementerio) {
    showToast('warning', 'Seleccione un cementerio')
    return
  }
  if (!nuevaUbicacion.clase || nuevaUbicacion.clase === 0) {
    showToast('warning', 'Error en clase')
    return
  }
  if (!nuevaUbicacion.seccion || nuevaUbicacion.seccion === 0) {
    showToast('warning', 'Error en sección')
    return
  }
  if (!nuevaUbicacion.linea || nuevaUbicacion.linea === 0) {
    showToast('warning', 'Error en línea')
    return
  }
  if (!nuevaUbicacion.fosa || nuevaUbicacion.fosa === 0) {
    showToast('warning', 'Error en fosa')
    return
  }

  showLoading('Verificando ubicación...', 'Validando datos')

  try {
    // Verificar ubicación
    const verificarResponse = await execute(
      'sp_duplicados_verificar_ubicacion',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: nuevaUbicacion.cementerio, tipo: 'string' },
        { nombre: 'p_clase', valor: nuevaUbicacion.clase, tipo: 'integer' },
        { nombre: 'p_clase_alfa', valor: nuevaUbicacion.clase_alfa || null, tipo: 'string' },
        { nombre: 'p_seccion', valor: nuevaUbicacion.seccion, tipo: 'integer' },
        { nombre: 'p_seccion_alfa', valor: nuevaUbicacion.seccion_alfa || null, tipo: 'string' },
        { nombre: 'p_linea', valor: nuevaUbicacion.linea, tipo: 'integer' },
        { nombre: 'p_linea_alfa', valor: nuevaUbicacion.linea_alfa || null, tipo: 'string' },
        { nombre: 'p_fosa', valor: nuevaUbicacion.fosa, tipo: 'integer' },
        { nombre: 'p_fosa_alfa', valor: nuevaUbicacion.fosa_alfa || null, tipo: 'string' },
        { nombre: 'p_fecing', valor: duplicadoSeleccionado.value.fecing, tipo: 'date' },
        { nombre: 'p_recing', valor: duplicadoSeleccionado.value.recing, tipo: 'integer' },
        { nombre: 'p_cajing', valor: duplicadoSeleccionado.value.cajing, tipo: 'string' },
        { nombre: 'p_opcaja', valor: duplicadoSeleccionado.value.opcaja, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public'
    )

    hideLoading()

    if (!verificarResponse?.result || verificarResponse.result.length === 0) {
      showToast('error', 'Error al verificar ubicación')
      return
    }

    const { existe_datos, existe_pago } = verificarResponse.result[0]

    // Validar según modo de operación
    if (operacion.value === '1') {
      // Solo pagos: debe existir datos
      if (existe_datos !== 'S') {
        showToast('error', 'No se encuentran Datos en el Archivo de Cementerios')
        return
      }
      if (existe_pago === 'S') {
        showToast('error', 'Ya se encuentran Datos en el Archivo de Pagos')
        return
      }
    } else {
      // Todo: no deben existir datos
      if (existe_datos === 'S') {
        showToast('error', 'Ya se encuentran Datos en el Archivo de Cementerios')
        return
      }
      if (existe_pago === 'S') {
        showToast('error', 'Ya se encuentran Datos en el Archivo de Pagos')
        return
      }
    }

    // Confirmar traslado
    const result = await Swal.fire({
      title: '¿Confirmar traslado?',
      html: `
        <div style="text-align: left;">
          <p><strong>Registro:</strong> ${duplicadoSeleccionado.value.nombre}</p>
          <p><strong>Nueva ubicación:</strong> ${formatearUbicacion(nuevaUbicacion)}</p>
          <p><strong>Modo:</strong> ${operacion.value === '1' ? 'Solo Pagos' : 'Todo'}</p>
        </div>
      `,
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: 'Sí, trasladar',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d'
    })

    if (!result.isConfirmed) return

    showLoading('Trasladando duplicado...', 'Actualizando base de datos')

    // Ejecutar traslado
    const trasladoResponse = await execute(
      'spd_trasladar_duplicado',
      'cementerio',
      [
        { nombre: 'p_control_id', valor: duplicadoSeleccionado.value.control_id, tipo: 'integer' },
        { nombre: 'p_operacion', valor: parseInt(operacion.value), tipo: 'integer' },
        { nombre: 'p_cementerio', valor: nuevaUbicacion.cementerio, tipo: 'string' },
        { nombre: 'p_clase', valor: nuevaUbicacion.clase, tipo: 'integer' },
        { nombre: 'p_clase_alfa', valor: nuevaUbicacion.clase_alfa || null, tipo: 'string' },
        { nombre: 'p_seccion', valor: nuevaUbicacion.seccion, tipo: 'integer' },
        { nombre: 'p_seccion_alfa', valor: nuevaUbicacion.seccion_alfa || null, tipo: 'string' },
        { nombre: 'p_linea', valor: nuevaUbicacion.linea, tipo: 'integer' },
        { nombre: 'p_linea_alfa', valor: nuevaUbicacion.linea_alfa || null, tipo: 'string' },
        { nombre: 'p_fosa', valor: nuevaUbicacion.fosa, tipo: 'integer' },
        { nombre: 'p_fosa_alfa', valor: nuevaUbicacion.fosa_alfa || null, tipo: 'string' },
        { nombre: 'p_tipo', valor: nuevaUbicacion.tipo, tipo: 'string' },
        { nombre: 'p_observaciones', valor: nuevaUbicacion.observaciones || null, tipo: 'string' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: obtener de sesión
      ],
      'cementerio',
      null,
      'public'
    )

    if (!trasladoResponse?.result || trasladoResponse.result.length === 0) {
      showToast('error', 'Error al trasladar duplicado')
      return
    }

    const resultado = trasladoResponse.result[0]
    if (resultado.resultado === 'S') {
      showToast('success', 'El Registro se ha trasladado correctamente')
      // Refrescar búsqueda
      await buscarDuplicados()
      duplicadoSeleccionado.value = null
      limpiarFormulario()
    } else {
      showToast('error', resultado.mensaje || 'Error al trasladar')
    }
  } catch (error) {
    console.error('Error al trasladar duplicado:', error)
    showToast('error', 'Error al trasladar el duplicado')
  } finally {
    hideLoading()
  }
}
// Para evitar SP adicionales, agregamos un SP generico 
const cargarCementerios = async () => {
  try {
    const response = await execute(
      //'sp_duplicados_listar_cementerios',
      'sp_get_cementerios_list',
      'cementerio',
      [],
      'cementerio',
      null,
      'public'
    )
    cementerios.value = response?.result || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar cementerios')
  }
}

const formatearUbicacion = (obj) => {
  const partes = []
  partes.push(`Cl:${obj.clase}${obj.clase_alfa || ''}`)
  partes.push(`Sec:${obj.seccion}${obj.seccion_alfa || ''}`)
  partes.push(`Lin:${obj.linea}${obj.linea_alfa || ''}`)
  partes.push(`Fosa:${obj.fosa}${obj.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearDomicilio = (obj) => {
  const partes = [obj.domicilio]
  if (obj.exterior) partes.push(`#${obj.exterior}`)
  if (obj.interior) partes.push(`Int.${obj.interior}`)
  if (obj.colonia) partes.push(obj.colonia)
  return partes.filter(p => p).join(', ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (valor == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(valor)
}

onMounted(() => {
  cargarCementerios()
})
</script>
