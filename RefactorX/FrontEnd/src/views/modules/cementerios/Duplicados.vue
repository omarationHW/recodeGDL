<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-copy"></i>
        Registros Duplicados
      </h1>
      <DocumentationModal
        title="Ayuda - Registros Duplicados"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de duplicados -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar Duplicados
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Nombre del Titular</label>
            <input
              v-model="busqueda.nombre"
              type="text"
              class="form-control"
              placeholder="Ingrese nombre a buscar"
              @keyup.enter="buscarDuplicados"
            />
          </div>
          <div class="form-group align-end">
            <button @click="buscarDuplicados" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Grid de duplicados encontrados -->
    <div v-if="duplicados.length > 0" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Duplicados Encontrados ({{ duplicados.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
                :class="{ 'selected-row': duplicadoSeleccionado?.control_id === dup.control_id }"
              >
                <td>{{ dup.nombre }}</td>
                <td>{{ formatearDomicilio(dup) }}</td>
                <td>{{ formatearUbicacion(dup) }}</td>
                <td>{{ formatearFecha(dup.fecing) }}</td>
                <td>{{ dup.axo_pago_desde }} - {{ dup.axo_pago_hasta }}</td>
                <td>{{ formatearMoneda(dup.importe_anual) }}</td>
                <td>
                  <button
                    @click="seleccionarDuplicado(dup)"
                    class="btn-municipal-secondary btn-sm"
                  >
                    <i class="fas fa-check"></i>
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
    <div v-if="duplicadoSeleccionado" class="card">
      <div class="card-header">
        <i class="fas fa-exchange-alt"></i>
        Trasladar Duplicado: {{ duplicadoSeleccionado.nombre }}
      </div>
      <div class="card-body">
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
              <select v-model="nuevaUbicacion.cementerio" class="form-control">
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
                class="form-control"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Clase Alfa</label>
              <input
                v-model="nuevaUbicacion.clase_alfa"
                type="text"
                class="form-control"
                maxlength="2"
              />
            </div>
            <div class="form-group">
              <label class="form-label required">Sección</label>
              <input
                v-model.number="nuevaUbicacion.seccion"
                type="number"
                class="form-control"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Sección Alfa</label>
              <input
                v-model="nuevaUbicacion.seccion_alfa"
                type="text"
                class="form-control"
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
                class="form-control"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Línea Alfa</label>
              <input
                v-model="nuevaUbicacion.linea_alfa"
                type="text"
                class="form-control"
                maxlength="2"
              />
            </div>
            <div class="form-group">
              <label class="form-label required">Fosa</label>
              <input
                v-model.number="nuevaUbicacion.fosa"
                type="number"
                class="form-control"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Fosa Alfa</label>
              <input
                v-model="nuevaUbicacion.fosa_alfa"
                type="text"
                class="form-control"
                maxlength="4"
              />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Observaciones</label>
            <textarea
              v-model="nuevaUbicacion.observaciones"
              class="form-control"
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
            <i class="fas fa-check"></i>
            Trasladar Duplicado
          </button>
          <button @click="cancelarSeleccion" class="btn-municipal-secondary">
            <i class="fas fa-times"></i>
            Cancelar
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="duplicados.length === 0 && busqueda.nombre" class="alert-info">
      <i class="fas fa-info-circle"></i>
      No se encontraron duplicados con el nombre especificado
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const api = useApi()
const toast = useToast()

const busqueda = reactive({
  nombre: ''
})

const duplicados = ref([])
const duplicadoSeleccionado = ref(null)
const cementerios = ref([])
const operacion = ref('2')

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

const helpSections = [
  {
    title: 'Registros Duplicados',
    content: `
      <p>Este módulo permite gestionar registros que fueron capturados incorrectamente o en ubicaciones duplicadas.</p>
      <h4>Proceso:</h4>
      <ol>
        <li><strong>Buscar:</strong> Ingrese el nombre del titular para buscar duplicados</li>
        <li><strong>Seleccionar:</strong> Elija el registro duplicado a trasladar</li>
        <li><strong>Ubicación:</strong> Especifique la ubicación correcta (cementerio, clase, sección, línea, fosa)</li>
        <li><strong>Modo:</strong> Seleccione si solo traslada pagos o todo el registro</li>
        <li><strong>Trasladar:</strong> Confirme la operación</li>
      </ol>
    `
  },
  {
    title: 'Modos de Operación',
    content: `
      <p><strong>Solo Pagos:</strong> Use esta opción cuando los datos del titular ya existan en la ubicación correcta y solo necesite trasladar los pagos.</p>
      <p><strong>Todo:</strong> Use esta opción para crear un nuevo registro con los datos del titular y trasladar los pagos a la nueva ubicación.</p>
    `
  }
]

const buscarDuplicados = async () => {
  if (!busqueda.nombre.trim()) {
    toast.warning('Ingrese un nombre para buscar')
    return
  }

  try {
    const patron = `%${busqueda.nombre}%`
    const response = await api.callStoredProcedure('SP_CEM_BUSCAR_DUPLICADOS', {
      p_nombre: patron
    })

    duplicados.value = response.data || []
    duplicadoSeleccionado.value = null

    if (duplicados.value.length === 0) {
      toast.info('No se encontraron duplicados')
    } else {
      toast.success(`Se encontraron ${duplicados.value.length} duplicado(s)`)
    }
  } catch (error) {
    console.error('Error al buscar duplicados:', error)
    toast.error('Error al buscar duplicados')
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
    toast.warning('Seleccione un cementerio')
    return
  }
  if (!nuevaUbicacion.clase || nuevaUbicacion.clase === 0) {
    toast.warning('Error en clase')
    return
  }
  if (!nuevaUbicacion.seccion || nuevaUbicacion.seccion === 0) {
    toast.warning('Error en sección')
    return
  }
  if (!nuevaUbicacion.linea || nuevaUbicacion.linea === 0) {
    toast.warning('Error en línea')
    return
  }
  if (!nuevaUbicacion.fosa || nuevaUbicacion.fosa === 0) {
    toast.warning('Error en fosa')
    return
  }

  try {
    // Verificar ubicación
    const verificacion = await api.callStoredProcedure('SP_CEM_VERIFICAR_UBICACION_DUPLICADO', {
      p_cementerio: nuevaUbicacion.cementerio,
      p_clase: nuevaUbicacion.clase,
      p_clase_alfa: nuevaUbicacion.clase_alfa || null,
      p_seccion: nuevaUbicacion.seccion,
      p_seccion_alfa: nuevaUbicacion.seccion_alfa || null,
      p_linea: nuevaUbicacion.linea,
      p_linea_alfa: nuevaUbicacion.linea_alfa || null,
      p_fosa: nuevaUbicacion.fosa,
      p_fosa_alfa: nuevaUbicacion.fosa_alfa || null,
      p_fecing: duplicadoSeleccionado.value.fecing,
      p_recing: duplicadoSeleccionado.value.recing,
      p_cajing: duplicadoSeleccionado.value.cajing,
      p_opcaja: duplicadoSeleccionado.value.opcaja
    })

    const { existe_datos, existe_pago } = verificacion.data[0]

    // Validar según modo de operación
    if (operacion.value === '1') {
      // Solo pagos: debe existir datos
      if (existe_datos !== 'S') {
        toast.error('No se encuentran Datos en el Archivo de Cementerios')
        return
      }
      if (existe_pago === 'S') {
        toast.error('Ya se encuentran Datos en el Archivo de Pagos')
        return
      }
    } else {
      // Todo: no deben existir datos
      if (existe_datos === 'S') {
        toast.error('Ya se encuentran Datos en el Archivo de Cementerios')
        return
      }
      if (existe_pago === 'S') {
        toast.error('Ya se encuentran Datos en el Archivo de Pagos')
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
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    // Ejecutar traslado
    const response = await api.callStoredProcedure('SP_CEM_TRASLADAR_DUPLICADO', {
      p_control_id: duplicadoSeleccionado.value.control_id,
      p_operacion: parseInt(operacion.value),
      p_cementerio: nuevaUbicacion.cementerio,
      p_clase: nuevaUbicacion.clase,
      p_clase_alfa: nuevaUbicacion.clase_alfa || null,
      p_seccion: nuevaUbicacion.seccion,
      p_seccion_alfa: nuevaUbicacion.seccion_alfa || null,
      p_linea: nuevaUbicacion.linea,
      p_linea_alfa: nuevaUbicacion.linea_alfa || null,
      p_fosa: nuevaUbicacion.fosa,
      p_fosa_alfa: nuevaUbicacion.fosa_alfa || null,
      p_tipo: nuevaUbicacion.tipo,
      p_observaciones: nuevaUbicacion.observaciones || null,
      p_usuario: 1 // TODO: obtener del contexto de usuario
    })

    const resultado = response.data[0]
    if (resultado.resultado === 'S') {
      toast.success('El Registro se ha trasladado')
      // Refrescar búsqueda
      await buscarDuplicados()
      duplicadoSeleccionado.value = null
      limpiarFormulario()
    } else {
      toast.error(resultado.mensaje)
    }
  } catch (error) {
    console.error('Error al trasladar duplicado:', error)
    toast.error('Error al trasladar el duplicado')
  }
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    toast.error('Error al cargar cementerios')
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

<style scoped>
.selected-row {
  background-color: var(--color-primary-light);
  font-weight: 500;
}

.radio-group {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.radio-option input[type="radio"] {
  cursor: pointer;
}

.align-end {
  display: flex;
  align-items: flex-end;
}

.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}
</style>
