<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="folder-open module-icon" />
        <div>
          <h1 class="module-view-info">ABC de Folios RCM</h1>
          <p class="module-subtitle">Alta, Baja y Cambio de Folios de Cementerios</p>
        </div>
      </div>
      <div class="module-actions">
        <button @click="showHelp = true" class="btn-icon" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
        </button>
      </div>
    </div>

    <div class="module-content">
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="search" />
          Buscar Folio
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-two">
            <div class="form-group">
              <label for="folioB uscar" class="municipal-form-label">Folio (Control RCM)</label>
              <input
                id="folioBuscar"
                v-model.number="folioBuscar"
                type="number"
                class="municipal-form-control"
                placeholder="Ingrese número de folio"
                @keyup.enter="buscarFolio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button
                @click="buscarFolio"
                class="btn-municipal-primary"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Edición -->
      <div v-if="mostrarFormulario" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="edit" />
          Datos del Folio
        </div>
        <div class="municipal-card-body">
          <!-- Cementerio -->
          <div class="form-group">
            <label for="cementerio" class="form-label required">Cementerio</label>
            <select
              id="cementerio"
              v-model="formData.cementerio"
              class="municipal-form-control"
            >
              <option value="">Seleccione...</option>
              <option
                v-for="cem in cementerios"
                :key="cem.cementerio"
                :value="cem.cementerio"
              >
                {{ cem.nombre }}
              </option>
            </select>
          </div>

          <!-- Ubicación de la Fosa -->
          <div class="section-title">Ubicación</div>
          <div class="form-grid-four">
            <div class="form-group">
              <label for="clase" class="municipal-form-label">Clase</label>
              <input
                id="clase"
                v-model.number="formData.clase"
                type="number"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="claseAlfa" class="municipal-form-label">Clase Alfa</label>
              <input
                id="claseAlfa"
                v-model="formData.clase_alfa"
                type="text"
                maxlength="2"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="seccion" class="municipal-form-label">Sección</label>
              <input
                id="seccion"
                v-model.number="formData.seccion"
                type="number"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="seccionAlfa" class="municipal-form-label">Sección Alfa</label>
              <input
                id="seccionAlfa"
                v-model="formData.seccion_alfa"
                type="text"
                maxlength="2"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="form-grid-four">
            <div class="form-group">
              <label for="linea" class="municipal-form-label">Línea</label>
              <input
                id="linea"
                v-model.number="formData.linea"
                type="number"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="lineaAlfa" class="municipal-form-label">Línea Alfa</label>
              <input
                id="lineaAlfa"
                v-model="formData.linea_alfa"
                type="text"
                maxlength="2"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="fosa" class="municipal-form-label">Fosa</label>
              <input
                id="fosa"
                v-model.number="formData.fosa"
                type="number"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="fosaAlfa" class="municipal-form-label">Fosa Alfa</label>
              <input
                id="fosaAlfa"
                v-model="formData.fosa_alfa"
                type="text"
                maxlength="4"
                class="municipal-form-control"
              />
            </div>
          </div>

          <!-- Tipo de Espacio -->
          <div class="form-group">
            <label class="form-label required">Tipo de Espacio</label>
            <div class="radio-group-horizontal">
              <label class="radio-label">
                <input
                  v-model="formData.tipo"
                  type="radio"
                  value="F"
                />
                <span>Fosa</span>
              </label>
              <label class="radio-label">
                <input
                  v-model="formData.tipo"
                  type="radio"
                  value="U"
                />
                <span>Urna</span>
              </label>
              <label class="radio-label">
                <input
                  v-model="formData.tipo"
                  type="radio"
                  value="G"
                />
                <span>Gaveta</span>
              </label>
            </div>
          </div>

          <!-- Datos Administrativos -->
          <div class="section-title">Datos Administrativos</div>
          <div class="form-grid-two">
            <div class="form-group">
              <label for="axoPagado" class="form-label required">Último Año Pagado</label>
              <input
                id="axoPagado"
                v-model.number="formData.axo_pagado"
                type="number"
                :min="currentYear - 6"
                :max="currentYear + 1"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="metros" class="form-label required">Metros</label>
              <input
                id="metros"
                v-model.number="formData.metros"
                type="number"
                step="0.01"
                min="0"
                class="municipal-form-control"
              />
            </div>
          </div>

          <!-- Datos del Propietario -->
          <div class="section-title">Datos del Propietario</div>
          <div class="form-group">
            <label for="nombre" class="form-label required">Nombre</label>
            <input
              id="nombre"
              v-model="formData.nombre"
              type="text"
              maxlength="150"
              class="municipal-form-control"
            />
          </div>

          <div class="form-grid-three">
            <div class="form-group">
              <label for="domicilio" class="form-label required">Domicilio</label>
              <input
                id="domicilio"
                v-model="formData.domicilio"
                type="text"
                maxlength="150"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="exterior" class="form-label required">Número Exterior</label>
              <input
                id="exterior"
                v-model="formData.exterior"
                type="text"
                maxlength="10"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="interior" class="municipal-form-label">Número Interior</label>
              <input
                id="interior"
                v-model="formData.interior"
                type="text"
                maxlength="10"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="form-group">
            <label for="colonia" class="municipal-form-label">Colonia</label>
            <input
              id="colonia"
              v-model="formData.colonia"
              type="text"
              maxlength="100"
              class="municipal-form-control"
            />
          </div>

          <div class="form-group">
            <label for="observaciones" class="municipal-form-label">Observaciones</label>
            <textarea
              id="observaciones"
              v-model="formData.observaciones"
              maxlength="255"
              rows="3"
              class="municipal-form-control"
            ></textarea>
          </div>

          <!-- Datos Adicionales -->
          <div class="section-title">Datos Adicionales</div>
          <div class="form-grid-two">
            <div class="form-group">
              <label for="rfc" class="municipal-form-label">RFC</label>
              <input
                id="rfc"
                v-model="formData.rfc"
                type="text"
                maxlength="13"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="curp" class="municipal-form-label">CURP</label>
              <input
                id="curp"
                v-model="formData.curp"
                type="text"
                maxlength="18"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="form-grid-two">
            <div class="form-group">
              <label for="telefono" class="municipal-form-label">Teléfono</label>
              <input
                id="telefono"
                v-model="formData.telefono"
                type="text"
                maxlength="20"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="claveIfe" class="municipal-form-label">Clave IFE/INE</label>
              <input
                id="claveIfe"
                v-model="formData.clave_ife"
                type="text"
                maxlength="30"
                class="municipal-form-control"
              />
            </div>
          </div>

          <!-- Acciones -->
          <div class="form-actions">
            <button
              @click="guardarCambios"
              class="btn-municipal-primary"
              :disabled="!formValid"
            >
              <font-awesome-icon icon="save" />
              Guardar Cambios
            </button>
            <button
              @click="confirmarBaja"
              class="btn-danger"
            >
              <font-awesome-icon icon="trash" />
              Dar de Baja
            </button>
            <button
              @click="cancelar"
              class="btn-municipal-secondary"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="showHelp"
      title="ABC de Folios RCM"
      @close="showHelp = false"
    >
      <div class="help-content">
        <h3>Descripción</h3>
        <p>
          Este módulo permite gestionar folios RCM (cuentas de cementerios), incluyendo
          la modificación de datos y baja de registros.
        </p>

        <h3>Instrucciones de Uso</h3>
        <ol>
          <li>Ingrese el número de folio (Control RCM) a buscar</li>
          <li>Haga clic en "Buscar" o presione Enter</li>
          <li>Si el folio existe, se mostrará el formulario con los datos actuales</li>
          <li>Modifique los campos necesarios</li>
          <li>Haga clic en "Guardar Cambios" para aplicar las modificaciones</li>
          <li>Use "Dar de Baja" para marcar el folio como inactivo</li>
        </ol>

        <h3>Notas Importantes</h3>
        <ul>
          <li>Los campos marcados con asterisco (*) son obligatorios</li>
          <li>El último año pagado debe estar entre el año actual -6 y el año actual +1</li>
          <li>La baja de un folio es reversible solo por un administrador</li>
          <li>Los datos adicionales (RFC, CURP, etc.) son opcionales pero recomendados</li>
        </ul>

        <h3>Campos Requeridos</h3>
        <ul>
          <li><strong>Cementerio:</strong> Cementerio municipal</li>
          <li><strong>Último Año Pagado:</strong> Año del último pago realizado</li>
          <li><strong>Metros:</strong> Metros cuadrados del espacio</li>
          <li><strong>Nombre:</strong> Nombre del propietario</li>
          <li><strong>Domicilio:</strong> Dirección del propietario</li>
          <li><strong>Número Exterior:</strong> Número exterior del domicilio</li>
        </ul>
      </div>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showSuccess, showError, showWarning } = useToast()

// Estado
const showHelp = ref(false)
const folioBuscar = ref(null)
const mostrarFormulario = ref(false)
const cementerios = ref([])
const currentYear = new Date().getFullYear()
const folioOriginal = ref(null)

// Formulario
const formData = ref({
  control_rcm: null,
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: '',
  axo_pagado: null,
  metros: null,
  nombre: '',
  domicilio: '',
  exterior: '',
  interior: '',
  colonia: '',
  observaciones: '',
  tipo: 'F',
  rfc: '',
  curp: '',
  telefono: '',
  clave_ife: '',
  vigencia: 'A'
})

// Validación del formulario
const formValid = computed(() => {
  return (
    formData.value.cementerio &&
    formData.value.nombre &&
    formData.value.domicilio &&
    formData.value.exterior &&
    formData.value.axo_pagado > 0 &&
    formData.value.metros > 0
  )
})

// Cargar cementerios
const cargarCementerios = async () => {
  try {
    const response = await execute(
      'sp_cem_listar_cementerios',
      'cementerios',
      {},
      '',
      null,
      'comun'
    )

    if (response && response.result) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showError('Error al cargar la lista de cementerios')
  }
}

// Buscar folio
const buscarFolio = async () => {
  if (!folioBuscar.value) {
    showWarning('Ingrese un número de folio')
    return
  }

  try {
    const response = await execute(
      'sp_cem_buscar_folio',
      'cementerios',
      { p_control_rcm: folioBuscar.value },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S' && response.result && response.result.length > 0) {
      const folio = response.result[0]

      // Verificar si está dado de baja
      if (folio.vigencia === 'B') {
        showWarning('Este folio está dado de baja')
        mostrarFormulario.value = false
        return
      }

      // Cargar datos en el formulario
      formData.value = {
        control_rcm: folio.control_rcm,
        cementerio: folio.cementerio,
        clase: folio.clase,
        clase_alfa: folio.clase_alfa || '',
        seccion: folio.seccion,
        seccion_alfa: folio.seccion_alfa || '',
        linea: folio.linea,
        linea_alfa: folio.linea_alfa || '',
        fosa: folio.fosa,
        fosa_alfa: folio.fosa_alfa || '',
        axo_pagado: folio.axo_pagado,
        metros: folio.metros,
        nombre: folio.nombre || '',
        domicilio: folio.domicilio || '',
        exterior: folio.exterior || '',
        interior: folio.interior || '',
        colonia: folio.colonia || '',
        observaciones: folio.observaciones || '',
        tipo: folio.tipo || 'F',
        rfc: folio.rfc || '',
        curp: folio.curp || '',
        telefono: folio.telefono || '',
        clave_ife: folio.clave_ife || '',
        vigencia: folio.vigencia
      }

      // Guardar copia del original
      folioOriginal.value = JSON.parse(JSON.stringify(formData.value))

      mostrarFormulario.value = true
      showSuccess('Folio encontrado')
    } else {
      showError(response?.mensaje || 'Folio no encontrado')
      mostrarFormulario.value = false
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showError('Error al buscar el folio')
    mostrarFormulario.value = false
  }
}

// Guardar cambios
const guardarCambios = async () => {
  if (!formValid.value) {
    showWarning('Complete todos los campos requeridos')
    return
  }

  // Validar año pagado
  if (formData.value.axo_pagado < currentYear - 6) {
    showWarning('El último año pagado no puede ser menor a ' + (currentYear - 6))
    return
  }

  if (formData.value.axo_pagado > currentYear + 1) {
    showWarning('El último año pagado no puede ser mayor a ' + (currentYear + 1))
    return
  }

  try {
    const response = await execute(
      'sp_cem_modificar_folio',
      'cementerios',
      {
        p_control_rcm: formData.value.control_rcm,
        p_cementerio: formData.value.cementerio,
        p_clase: formData.value.clase,
        p_clase_alfa: formData.value.clase_alfa,
        p_seccion: formData.value.seccion,
        p_seccion_alfa: formData.value.seccion_alfa,
        p_linea: formData.value.linea,
        p_linea_alfa: formData.value.linea_alfa,
        p_fosa: formData.value.fosa,
        p_fosa_alfa: formData.value.fosa_alfa,
        p_axo_pagado: formData.value.axo_pagado,
        p_metros: formData.value.metros,
        p_nombre: formData.value.nombre,
        p_domicilio: formData.value.domicilio,
        p_exterior: formData.value.exterior,
        p_interior: formData.value.interior,
        p_colonia: formData.value.colonia,
        p_observaciones: formData.value.observaciones,
        p_tipo: formData.value.tipo,
        p_usuario: 1, // TODO: Obtener del contexto de usuario
        p_rfc: formData.value.rfc,
        p_curp: formData.value.curp,
        p_telefono: formData.value.telefono,
        p_clave_ife: formData.value.clave_ife
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S') {
      showSuccess('Cambios guardados exitosamente')
      cancelar()
    } else {
      showError(response?.mensaje || 'Error al guardar cambios')
    }
  } catch (error) {
    console.error('Error al guardar cambios:', error)
    showError('Error al guardar cambios')
  }
}

// Confirmar baja
const confirmarBaja = async () => {
  const result = await Swal.fire({
    title: '¿Dar de baja este folio?',
    html: `
      <p>Está a punto de dar de baja el folio:</p>
      <p><strong>${formData.value.control_rcm}</strong></p>
      <p>Propietario: ${formData.value.nombre}</p>
      <p>Esta acción marcará el folio como inactivo.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6'
  })

  if (result.isConfirmed) {
    await darDeBaja()
  }
}

// Dar de baja
const darDeBaja = async () => {
  try {
    const response = await execute(
      'sp_cem_baja_folio',
      'cementerios',
      {
        p_control_rcm: formData.value.control_rcm,
        p_usuario: 1 // TODO: Obtener del contexto de usuario
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S') {
      showSuccess('Folio dado de baja exitosamente')
      cancelar()
    } else {
      showError(response?.mensaje || 'Error al dar de baja el folio')
    }
  } catch (error) {
    console.error('Error al dar de baja:', error)
    showError('Error al dar de baja el folio')
  }
}

// Cancelar
const cancelar = () => {
  mostrarFormulario.value = false
  folioBuscar.value = null
  formData.value = {
    control_rcm: null,
    cementerio: '',
    clase: null,
    clase_alfa: '',
    seccion: null,
    seccion_alfa: '',
    linea: null,
    linea_alfa: '',
    fosa: null,
    fosa_alfa: '',
    axo_pagado: null,
    metros: null,
    nombre: '',
    domicilio: '',
    exterior: '',
    interior: '',
    colonia: '',
    observaciones: '',
    tipo: 'F',
    rfc: '',
    curp: '',
    telefono: '',
    clave_ife: '',
    vigencia: 'A'
  }
}

// Inicialización
onMounted(() => {
  cargarCementerios()
})
</script>
