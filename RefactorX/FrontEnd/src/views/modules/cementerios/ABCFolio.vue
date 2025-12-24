<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="folder-open" />
      </div>
      <div class="module-view-info">
        <h1>ABC de Folios RCM</h1>
        <p>Alta, Baja y Cambio de Folios de Cementerios</p>
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
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label for="folioBuscar" class="municipal-form-label">Folio (Control RCM)</label>
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
                :disabled="!folioBuscar"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Edición -->
      <div v-if="mostrarFormulario" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Datos del Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Cementerio -->
          <div class="form-row">
            <div class="form-group full-width">
              <label for="cementerio" class="municipal-form-label">Cementerio <span class="required">*</span></label>
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
          </div>

          <!-- Ubicación de la Fosa -->
          <div class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación
          </div>
          <div class="form-row">
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

          <div class="form-row">
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
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Tipo de Espacio <span class="required">*</span></label>
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
          </div>

          <!-- Datos Administrativos -->
          <div class="section-title">
            <font-awesome-icon icon="clipboard-list" />
            Datos Administrativos
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="axoPagado" class="municipal-form-label">Último Año Pagado <span class="required">*</span></label>
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
              <label for="metros" class="municipal-form-label">Metros <span class="required">*</span></label>
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
          <div class="section-title">
            <font-awesome-icon icon="user" />
            Datos del Propietario
          </div>
          <div class="form-row">
            <div class="form-group full-width">
              <label for="nombre" class="municipal-form-label">Nombre <span class="required">*</span></label>
              <input
                id="nombre"
                v-model="formData.nombre"
                type="text"
                maxlength="150"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="domicilio" class="municipal-form-label">Domicilio <span class="required">*</span></label>
              <input
                id="domicilio"
                v-model="formData.domicilio"
                type="text"
                maxlength="150"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group">
              <label for="exterior" class="municipal-form-label">Número Exterior <span class="required">*</span></label>
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

          <div class="form-row">
            <div class="form-group full-width">
              <label for="colonia" class="municipal-form-label">Colonia</label>
              <input
                id="colonia"
                v-model="formData.colonia"
                type="text"
                maxlength="100"
                class="municipal-form-control"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label for="observaciones" class="municipal-form-label">Observaciones</label>
              <textarea
                id="observaciones"
                v-model="formData.observaciones"
                maxlength="255"
                rows="3"
                class="municipal-form-control"
              ></textarea>
            </div>
          </div>

          <!-- Datos Adicionales -->
          <div class="section-title">
            <font-awesome-icon icon="address-card" />
            Datos Adicionales
          </div>
          <div class="form-row">
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

          <div class="form-row">
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
          <div class="modal-actions">
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
              class="btn btn-danger"
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

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ABCFolio'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'ABC de Folios RCM'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

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
const folioBuscar = ref(null)
const mostrarFormulario = ref(false)
const cementerios = ref([])
const currentYear = new Date().getFullYear()
const folioOriginal = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)

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
    // ============================================================================
    // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
    // ============================================================================
    // Query SQL actual (basado en ABCFolio.pas línea 1479):
    /*
      SELECT cementerio, nombre, domicilio
      FROM cementerio.public.tc_13_cementerios
      ORDER BY cementerio
    */
    //
    // SP sugerido: sp_get_cementerios_list()
    // RETURNS TABLE(cementerio VARCHAR(1), nombre VARCHAR(50), domicilio VARCHAR(100))
    // Base de datos: cementerio
    // Esquema: public (según postgreok.csv: tc_13_cementerios → cementerio.public)
    // ============================================================================

    const response = await execute(
      'sp_get_cementerios_list',
      'cementerio',
      [],
      '',
      null,
      'public'
    )

    if (response && response.result) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar la lista de cementerios')
  }
}

// Buscar folio
const buscarFolio = async () => {
  if (!folioBuscar.value) {
    showToast('warning', 'Ingrese un número de folio')
    return
  }

  showLoading('Buscando folio...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // ============================================================================
    // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
    // ============================================================================
    // Query SQL actual (basado en ABCFolio.pas línea 1335-1337):
    /*
      SELECT a.control_rcm, a.cementerio, a.clase, a.clase_alfa,
             a.seccion, a.seccion_alfa, a.linea, a.linea_alfa,
             a.fosa, a.fosa_alfa, a.axo_pagado, a.metros,
             a.nombre, a.domicilio, a.exterior, a.interior,
             a.colonia, a.observaciones, a.usuario, a.fecha_mov,
             a.tipo, a.fecha_alta, a.vigencia,
             c.nombre as usuario_nombre, c.id_rec
      FROM padron_licencias.comun.ta_13_datosrcm a
      LEFT JOIN padron_licencias.comun.ta_12_passwords c ON a.usuario = c.id_usuario
      WHERE a.control_rcm = $1
    */
    //
    // SP sugerido: sp_abcf_get_folio(p_folio INTEGER)
    // RETURNS TABLE(control_rcm INTEGER, cementerio VARCHAR, clase INTEGER, ...)
    // Base de datos: padron_licencias
    // Esquema: comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
    // ============================================================================

    // 1. Buscar datos principales con LEFT JOIN a ta_12_passwords
    const responsePrincipal = await execute(
      'sp_abcf_get_folio',
      'padron_licencias',
      [{ nombre: 'p_folio', valor: folioBuscar.value, tipo: 'integer' }],
      '',
      null,
      'publico'
    )

    if (responsePrincipal?.result?.length > 0) {
      const folio = responsePrincipal.result[0]

      // Verificar si está dado de baja (como Pascal línea 351)
      if (folio.vigencia === 'B') {
        showToast('warning', 'Este folio está dado de baja')
        mostrarFormulario.value = false
        hideLoading()
        return
      }

      // Cargar datos principales
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
        vigencia: folio.vigencia,
        // Temporales para datos adicionales
        rfc: '',
        curp: '',
        telefono: '',
        clave_ife: ''
      }

      // ============================================================================
      // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
      // ============================================================================
      // Query SQL actual (basado en ABCFolio.pas línea 1619):
      /*
        SELECT control_rcm, rfc, curp, telefono, clave_ife
        FROM cementerio.public.ta_13_datosrcmadic
        WHERE control_rcm = $1
      */
      //
      // SP sugerido: sp_abcf_get_adicional(p_folio INTEGER)
      // RETURNS TABLE(control_rcm INTEGER, rfc VARCHAR, curp VARCHAR, telefono VARCHAR, clave_ife VARCHAR)
      // Base de datos: cementerio
      // Esquema: public (según postgreok.csv: ta_13_datosrcmadic → cementerio.public)
      // ============================================================================

      // 2. Buscar datos adicionales
      const responseAdicional = await execute(
        'sp_abcf_get_adicional',
        'cementerio',
        [{ nombre: 'p_folio', valor: folioBuscar.value, tipo: 'integer' }],
        '',
        null,
        'public'
      )

      // Si existen datos adicionales, cargarlos (Pascal línea 380-393)
      if (responseAdicional?.result?.length > 0) {
        const adicional = responseAdicional.result[0]
        formData.value.rfc = adicional.rfc || ''
        formData.value.curp = adicional.curp || ''
        formData.value.telefono = adicional.telefono || ''
        formData.value.clave_ife = adicional.clave_ife || ''
      }

      // Guardar copia del original
      folioOriginal.value = JSON.parse(JSON.stringify(formData.value))

      mostrarFormulario.value = true
      showToast('success', 'Folio encontrado')
    } else {
      showToast('error', 'Folio no encontrado') // Pascal línea 406
      mostrarFormulario.value = false
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar el folio')
    mostrarFormulario.value = false
  } finally {
    hideLoading()
  }
}

// Guardar cambios
const guardarCambios = async () => {
  // Validaciones (Pascal línea 427-439)
  if (!formValid.value) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  // Validar año pagado
  if (formData.value.axo_pagado < currentYear - 6) {
    showToast('warning', `El último año pagado no puede ser menor a ${currentYear - 6}`)
    return
  }

  if (formData.value.axo_pagado > currentYear + 1) {
    showToast('warning', `El último año pagado no puede ser mayor a ${currentYear + 1}`)
    return
  }

  showLoading('Guardando cambios...', 'Por favor espere')
  try {
    // ============================================================================
    // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
    // ============================================================================
    // Query SQL actual (basado en ABCFolio.pas línea 197-228):
    /*
      UPDATE padron_licencias.comun.ta_13_datosrcm
      SET cementerio = $1, clase = $2, clase_alfa = $3,
          seccion = $4, seccion_alfa = $5, linea = $6, linea_alfa = $7,
          fosa = $8, fosa_alfa = $9, axo_pagado = $10, metros = $11,
          nombre = $12, domicilio = $13, exterior = $14, interior = $15,
          colonia = $16, observaciones = $17, tipo = $18,
          usuario = $19, fecha_mov = CURRENT_DATE
      WHERE control_rcm = $20
    */
    //
    // SP sugerido: sp_abcf_update_folio(p_control_rcm, p_cementerio, p_clase, ...)
    // RETURNS TABLE(resultado BOOLEAN, mensaje VARCHAR)
    // Base de datos: padron_licencias
    // Esquema: comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
    // NOTA: El SP debe llamar internamente a sp_13_historia y spd_abc_adercm
    // ============================================================================

    // 1. Guardar histórico ANTES de actualizar (Pascal línea 185-187) ya no utilizado
    // await execute(
    //   'sp_13_historia',
    //   'padron_licencias',
    //   { par_control: formData.value.control_rcm },
    //   '',
    //   null,
    //   'public'
    // )

    // 2. Actualizar datos principales
    const responsePrincipal = await execute(
      'sp_abcf_update_folio',
      'padron_licencias',
      [
        { nombre: 'p_folio',          valor: formData.value.control_rcm,       tipo: 'integer' },
        { nombre: 'p_cementerio',     valor: formData.value.cementerio,        tipo: 'string' },
        { nombre: 'p_clase',          valor: formData.value.clase,             tipo: 'integer' },
        { nombre: 'p_clase_alfa',     valor: formData.value.clase_alfa,        tipo: 'string' },
        { nombre: 'p_seccion',        valor: formData.value.seccion,           tipo: 'integer' },
        { nombre: 'p_seccion_alfa',   valor: formData.value.seccion_alfa,      tipo: 'string' },
        { nombre: 'p_linea',          valor: formData.value.linea,             tipo: 'integer' },
        { nombre: 'p_linea_alfa',     valor: formData.value.linea_alfa,        tipo: 'string' },
        { nombre: 'p_fosa',           valor: formData.value.fosa,              tipo: 'integer' },
        { nombre: 'p_fosa_alfa',      valor: formData.value.fosa_alfa,         tipo: 'string' },
        { nombre: 'p_axo_pagado',     valor: formData.value.axo_pagado,        tipo: 'integer' },
        { nombre: 'p_metros',         valor: formData.value.metros,            tipo: 'numeric' },
        { nombre: 'p_nombre',         valor: formData.value.nombre,            tipo: 'string' },
        { nombre: 'p_domicilio',      valor: formData.value.domicilio,         tipo: 'string' },
        { nombre: 'p_exterior',       valor: formData.value.exterior,          tipo: 'string' },
        { nombre: 'p_interior',       valor: formData.value.interior,          tipo: 'string' },
        { nombre: 'p_colonia',        valor: formData.value.colonia,           tipo: 'string' },
        { nombre: 'p_observaciones',  valor: formData.value.observaciones,     tipo: 'string' },
        { nombre: 'p_tipo',           valor: formData.value.tipo,              tipo: 'string' },
        { nombre: 'p_usuario',        valor: 1,                                tipo: 'integer' } // TODO: Obtener del contexto de usuario
      ],
      '',
      null,
      'publico'
    )

    if (!responsePrincipal || responsePrincipal.affectedRows === 0) {
      throw new Error('Error al actualizar datos principales')
    }

    // ============================================================================
    // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
    // ============================================================================
    // Query SQL actual (basado en ABCFolio.pas línea 249-277):
    /*
      -- Si existe:
      UPDATE cementerio.public.ta_13_datosrcmadic
      SET rfc = $1, curp = $2, telefono = $3, clave_ife = $4
      WHERE control_rcm = $5

      -- Si no existe:
      INSERT INTO cementerio.public.ta_13_datosrcmadic
      (control_rcm, rfc, curp, telefono, clave_ife)
      VALUES ($1, $2, $3, $4, $5)
    */
    //
    // SP sugerido: sp_abcf_update_adicional(p_control_rcm, p_rfc, p_curp, p_telefono, p_clave_ife)
    // RETURNS TABLE(resultado BOOLEAN, mensaje VARCHAR)
    // Base de datos: cementerio
    // Esquema: public (según postgreok.csv: ta_13_datosrcmadic → cementerio.public)
    // NOTA: El SP debe hacer UPSERT (INSERT ON CONFLICT UPDATE)
    // ============================================================================

    // 3. Actualizar/Insertar datos adicionales
    await execute(
      'sp_abcf_update_adicional',
      'cementerio',
      [
        { nombre: 'p_folio',       valor: formData.value.control_rcm,  tipo: 'integer'},
        { nombre: 'p_rfc',         valor: formData.value.rfc,          tipo: 'string' },
        { nombre: 'p_curp',        valor: formData.value.curp,         tipo: 'string' },
        { nombre: 'p_telefono',    valor: formData.value.telefono,     tipo: 'string' },
        { nombre: 'p_clave_ife',   valor: formData.value.clave_ife,    tipo: 'string' }
      ],
      '',
      null,
      'public'
    )

    // 4. Recalcular adeudos DESPUÉS de actualizar (Pascal línea 236-240)
    // await execute(
    //   'spd_abc_adercm',
    //   'padron_licencias',
    //   [
    //     { nombre: 'par_control', valor: formData.value.control_rcm, tipo: 'integer' },
    //     { nombre: 'par_opc',     valor: 3,                          tipo: 'integer' }, // 3 = Modificación
    //     { nombre: 'par_usu',     valor: 1,                          tipo: 'integer' }  // TODO: Obtener del contexto de usuario
    //   ],
    //   '',
    //   null,
    //   'public'
    // )

    showToast('success', 'Cambios guardados exitosamente') // Pascal línea 235
    cancelar()
  } catch (error) {
    console.error('Error al guardar cambios:', error)
    showToast('error', error.message || 'Error al guardar cambios')
  } finally {
    hideLoading()
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
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await darDeBaja()
  }
}

// Dar de baja
const darDeBaja = async () => {
  showLoading('Dando de baja folio...', 'Por favor espere')
  try {
    // ============================================================================
    // TODO FUTURO: Este componente NO tiene SP en /ok/ ni /sp/ para esta función
    // ============================================================================
    // Query SQL actual (basado en ABCFolio.pas línea 299-341):
    /*
      UPDATE padron_licencias.comun.ta_13_datosrcm
      SET vigencia = 'B',
          usuario = $1,
          fecha_mov = CURRENT_DATE
      WHERE control_rcm = $2
    */
    //
    // SP sugerido: sp_abcf_baja_folio(p_control_rcm, p_usuario)
    // RETURNS TABLE(resultado BOOLEAN, mensaje VARCHAR)
    // Base de datos: padron_licencias
    // Esquema: comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
    // NOTA: El SP debe llamar internamente a sp_13_historia y spd_abc_adercm
    // ============================================================================

    // 1. Guardar histórico ANTES de dar de baja (Pascal línea 283-290)
    // await execute(
    //   'sp_13_historia',
    //   'padron_licencias',
    //   { par_control: formData.value.control_rcm },
    //   '',
    //   null,
    //   'public'
    // )

    // 2. Actualizar vigencia a 'B' (Baja) en datos principales
    const response = await execute(
      'sp_abcf_baja_folio',
      'padron_licencias',
      [
        { nombre: 'p_folio',   valor: formData.value.control_rcm, tipo: 'integer'},
        { nombre: 'p_usuario', valor: 1,                          tipo: 'integer'} // TODO: Obtener del contexto de usuario
      ],
      '',
      null,
      'publico'
    )

    if (!response || response.affectedRows === 0) {
      throw new Error('Error al dar de baja el folio')
    }

    // 3. Actualizar datos adicionales (opcional - Pascal línea 340-342 está comentado)
    // El Pascal original NO hace DELETE, solo lo tiene comentado
    // await execute('DELETE', 'cementerio', { ... }, '', null, 'public')

    // 4. Actualizar adeudos DESPUÉS de la baja (Pascal línea 327-331)
    await execute(
      'spd_abc_adercm',
      'padron_licencias',
      [
        { nombre: 'par_control', valor: formData.value.control_rcm, tipo: 'integer' },
        { nombre: 'par_opc',     valor: 2,                          tipo: 'integer' }, // 2 = Baja
        { nombre: 'par_usu',     valor: 1,                          tipo: 'integer' }  // TODO: Obtener del contexto de usuario
      ],
      '',
      null,
      'public'
    )

    showToast('success', 'Folio dado de baja exitosamente') // Pascal línea 326
    cancelar()
  } catch (error) {
    console.error('Error al dar de baja:', error)
    showToast('error', 'Error al dar de baja el folio')
  } finally {
    hideLoading()
  }
}

// Cancelar
const cancelar = () => {
  mostrarFormulario.value = false
  folioBuscar.value = null
  hasSearched.value = false
  selectedRow.value = null
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
