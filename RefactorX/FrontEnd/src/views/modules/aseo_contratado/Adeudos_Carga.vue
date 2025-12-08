<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Adeudos</h1>
        <p>Aseo Contratado - Generacion de adeudos para contratos vigentes</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Configuracion -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Configuracion de Carga</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            <div>
              <strong>Advertencia:</strong> Esta operacion generara adeudos mensuales (Enero a Diciembre)
              para TODOS los contratos vigentes del ejercicio seleccionado.
              El proceso puede tardar varios minutos.
            </div>
          </div>

          <div class="info-grid mt-3">
            <div class="info-item">
              <span class="info-label">Ejercicio Fiscal</span>
              <div class="info-value">
                <input
                  type="number"
                  v-model.number="ejercicio"
                  class="municipal-form-control"
                  :min="ejercicioActual - 5"
                  :max="ejercicioActual + 1"
                  style="max-width: 150px;"
                />
              </div>
            </div>
            <div class="info-item">
              <span class="info-label">Ejercicio Actual</span>
              <span class="info-value info-value-highlight">{{ ejercicioActual }}</span>
            </div>
          </div>

          <div class="municipal-alert municipal-alert-info mt-3">
            <font-awesome-icon icon="info-circle" />
            <div>
              <strong>Proceso:</strong>
              <ul class="mb-0 mt-2">
                <li>Se buscan todos los contratos con status Vigente (V) o Conveniado (N)</li>
                <li>Para cada contrato se generan 12 registros (uno por mes)</li>
                <li>El importe se calcula: cantidad_recoleccion x costo_unidad del ejercicio</li>
                <li>Los adeudos existentes no se duplican</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="ejecutarCarga"
              :disabled="procesando || !ejercicio"
            >
              <font-awesome-icon :icon="procesando ? 'spinner' : 'play'" :spin="procesando" />
              {{ procesando ? 'Procesando...' : 'Ejecutar Carga' }}
            </button>
            <button type="button" class="btn-municipal-secondary" @click="salir">
              <font-awesome-icon icon="door-open" /> Salir
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado -->
      <div v-if="resultado" class="municipal-card mt-3">
        <div class="municipal-card-header" :class="resultado.success ? 'municipal-card-header-success' : 'municipal-card-header-danger'">
          <h5>
            <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" />
            {{ resultado.success ? 'Carga Completada' : 'Error en Carga' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <p><strong>{{ resultado.mensaje }}</strong></p>
          <div v-if="resultado.success" class="info-grid">
            <div class="info-item">
              <span class="info-label">Contratos Procesados</span>
              <span class="info-value info-value-highlight">{{ resultado.contratos_procesados || 0 }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Adeudos Generados</span>
              <span class="info-value info-value-highlight">{{ resultado.adeudos_generados || 0 }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Tiempo de Proceso</span>
              <span class="info-value">{{ tiempoProceso }} segundos</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Carga de Adeudos"
      componentName="Adeudos_Carga"
    >
      <h3>Carga de Adeudos</h3>
      <p>Este modulo permite generar automaticamente los adeudos mensuales para todos los contratos vigentes de un ejercicio fiscal.</p>

      <h4>Proceso:</h4>
      <ol>
        <li>Ingrese el ejercicio fiscal (anio)</li>
        <li>Presione "Ejecutar Carga"</li>
        <li>Confirme la operacion</li>
        <li>El sistema generara 12 adeudos mensuales por cada contrato vigente</li>
        <li>Se calculara el importe segun las unidades y costos configurados</li>
      </ol>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>Solo se procesan contratos con status "Vigente" (V) o "Conveniado" (N)</li>
        <li>Si ya existen adeudos para un periodo, se omiten (no duplica)</li>
        <li>El proceso puede tardar varios minutos con muchos contratos</li>
        <li>Se recomienda ejecutar al inicio de cada ejercicio fiscal</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const ejercicioActual = new Date().getFullYear()
const ejercicio = ref(ejercicioActual)
const procesando = ref(false)
const resultado = ref(null)
const tiempoProceso = ref(0)

// Ejecutar carga masiva
const ejecutarCarga = async () => {
  if (!ejercicio.value) {
    showToast('Debe ingresar un ejercicio fiscal', 'warning')
    return
  }

  // Confirmar operacion
  const confirmResult = await Swal.fire({
    title: 'Confirmar Carga de Adeudos',
    html: `
      <div style="text-align: left; padding: 1rem 0;">
        <p><strong>Ejercicio:</strong> ${ejercicio.value}</p>
        <p>Se generaran adeudos mensuales (Enero a Diciembre) para todos los contratos vigentes.</p>
        <p class="text-warning"><strong>Esta operacion puede tardar varios minutos.</strong></p>
        <p>¿Desea continuar?</p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, ejecutar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#004085'
  })

  if (!confirmResult.isConfirmed) {
    showToast('Operacion cancelada', 'info')
    return
  }

  procesando.value = true
  resultado.value = null
  const startTime = Date.now()

  showLoading()
  try {
    const params = [
      { nombre: 'p_ejercicio', valor: ejercicio.value, tipo: 'integer' },
      { nombre: 'p_usuario_id', valor: 1, tipo: 'integer' }
    ]

    const data = await execute('sp_carga_adeudos_contratos_vigentes', BASE_DB, params, '', null, SCHEMA)

    tiempoProceso.value = ((Date.now() - startTime) / 1000).toFixed(2)
    hideLoading()

    if (data && data.length > 0) {
      const res = data[0]
      resultado.value = {
        success: res.success,
        mensaje: res.mensaje || 'Proceso completado',
        contratos_procesados: res.contratos_procesados || 0,
        adeudos_generados: res.adeudos_generados || 0
      }

      if (res.success) {
        await Swal.fire({
          title: 'Carga Completada',
          text: res.mensaje,
          icon: 'success'
        })
      } else {
        await Swal.fire({
          title: 'Error',
          text: res.mensaje,
          icon: 'error'
        })
      }
    } else {
      resultado.value = {
        success: true,
        mensaje: 'Proceso ejecutado',
        contratos_procesados: '-',
        adeudos_generados: '-'
      }
      await Swal.fire({
        title: 'Proceso Ejecutado',
        text: 'La carga de adeudos fue procesada',
        icon: 'success'
      })
    }

  } catch (error) {
    hideLoading()
    hideLoading()
    tiempoProceso.value = ((Date.now() - startTime) / 1000).toFixed(2)

    resultado.value = {
      success: false,
      mensaje: error.message || 'Error al ejecutar la carga masiva'
    }

    handleApiError(error, 'Error al ejecutar la carga')
  } finally {
    procesando.value = false
  }
}

// Salir
const salir = () => {
  router.push('/aseo-contratado')
}
</script>
