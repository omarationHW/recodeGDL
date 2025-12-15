<template>
  <div class="module-view">
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="arrow-up-right-dots" /></div>
      <div class="module-view-info">
        <h1>Actualizar Pagos — Estacionamientos Públicos</h1>
        <p>Actualiza fecha de baja/pago del folio</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="edit" /> Datos del Folio a Actualizar
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="form.alo"
                :min="2000"
                :max="2100"
                placeholder="Año"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio *</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="form.folio"
                placeholder="Número de folio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nueva Fecha de Baja/Pago *</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="form.fecbaj"
              />
            </div>
          </div>

          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="actualizar"
            >
              <font-awesome-icon icon="save" /> Actualizar Folio
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>

          <div v-if="loading" class="text-center py-3">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Procesando...</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Información de ayuda -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="info-circle" /> Información
        </div>
        <div class="municipal-card-body">
          <ul class="mb-0">
            <li>Este módulo actualiza la fecha de baja y pago de un folio existente.</li>
            <li>El folio quedará marcado con movimiento tipo 'R' (Regularizado).</li>
            <li>Ingrese el año y número de folio exactos para actualizar.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const form = reactive({
  alo: new Date().getFullYear(),
  folio: null,
  fecbaj: new Date().toISOString().split('T')[0]
})

function validarFormulario() {
  if (!form.alo || form.alo < 2000 || form.alo > 2100) {
    showToast('warning', 'El año es requerido y debe estar entre 2000 y 2100')
    return false
  }
  if (!form.folio || form.folio <= 0) {
    showToast('warning', 'El folio es requerido y debe ser mayor a 0')
    return false
  }
  if (!form.fecbaj) {
    showToast('warning', 'La fecha de baja es requerida')
    return false
  }
  return true
}

async function actualizar() {
  if (!validarFormulario()) return

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Actualización',
    html: `
      <p>¿Está seguro de actualizar el folio?</p>
      <ul class="swal-list-left">
        <li><strong>Año:</strong> ${form.alo}</li>
        <li><strong>Folio:</strong> ${form.folio}</li>
        <li><strong>Nueva Fecha:</strong> ${form.fecbaj}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Actualizando...', 'Guardando cambios del pago')
  try {
    const params = [
      { nombre: 'p_alo', valor: form.alo, tipo: 'integer' },
      { nombre: 'p_folio', valor: form.folio, tipo: 'integer' },
      { nombre: 'p_fecbaj', valor: form.fecbaj, tipo: 'date' }
    ]

    const resp = await execute('sp_up_pagos_update', BASE_DB, params, '', null, 'publico')
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Actualización Exitosa',
        text: data?.message || 'El folio ha sido actualizado correctamente',
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
      limpiar()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo actualizar el registro'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

function limpiar() {
  form.alo = new Date().getFullYear()
  form.folio = null
  form.fecbaj = new Date().toISOString().split('T')[0]
}
</script>
