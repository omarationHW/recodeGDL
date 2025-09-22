<template>
  <div class="licencias-module">
    <GenericModuleCrud
      module-name="licencias"
      module-title="Gestión de Licencias"
      module-description="Sistema de gestión y control de licencias municipales"
      :display-fields="displayFields"
      :form-fields="formFields"
    />
  </div>
</template>

<script>
import GenericModuleCrud from '@/components/GenericModuleCrud.vue'

export default {
  name: 'LicenciasWithBackend',
  
  components: {
    GenericModuleCrud
  },
  
  setup() {
    // Campos que se mostrarán en la tabla
    const displayFields = [
      { key: 'numero_licencia', label: 'No. Licencia' },
      { key: 'nombre_titular', label: 'Titular' },
      { key: 'tipo_actividad', label: 'Tipo de Actividad' },
      { key: 'direccion', label: 'Dirección' },
      { key: 'telefono', label: 'Teléfono' }
    ]
    
    // Campos del formulario de crear/editar
    const formFields = [
      {
        key: 'numero_licencia',
        label: 'Número de Licencia',
        type: 'text',
        required: true,
        colClass: 'col-md-6',
        placeholder: 'Ej: LIC-2024-001'
      },
      {
        key: 'nombre_titular',
        label: 'Nombre del Titular',
        type: 'text',
        required: true,
        colClass: 'col-md-6',
        placeholder: 'Nombre completo del titular'
      },
      {
        key: 'tipo_actividad',
        label: 'Tipo de Actividad',
        type: 'select',
        required: true,
        colClass: 'col-md-6',
        options: [
          { value: 'comercial', label: 'Comercial' },
          { value: 'industrial', label: 'Industrial' },
          { value: 'servicios', label: 'Servicios' },
          { value: 'restaurante', label: 'Restaurante' },
          { value: 'bar', label: 'Bar/Cantina' },
          { value: 'oficina', label: 'Oficina' },
          { value: 'otro', label: 'Otro' }
        ]
      },
      {
        key: 'categoria',
        label: 'Categoría',
        type: 'select',
        required: true,
        colClass: 'col-md-6',
        options: [
          { value: 'A', label: 'Categoría A' },
          { value: 'B', label: 'Categoría B' },
          { value: 'C', label: 'Categoría C' },
          { value: 'D', label: 'Categoría D' }
        ]
      },
      {
        key: 'direccion',
        label: 'Dirección',
        type: 'textarea',
        required: true,
        colClass: 'col-md-12',
        placeholder: 'Dirección completa del establecimiento'
      },
      {
        key: 'colonia',
        label: 'Colonia',
        type: 'text',
        required: true,
        colClass: 'col-md-6',
        placeholder: 'Nombre de la colonia'
      },
      {
        key: 'codigo_postal',
        label: 'Código Postal',
        type: 'text',
        required: true,
        colClass: 'col-md-6',
        placeholder: '44100'
      },
      {
        key: 'telefono',
        label: 'Teléfono',
        type: 'text',
        required: false,
        colClass: 'col-md-6',
        placeholder: '33-1234-5678'
      },
      {
        key: 'email',
        label: 'Email',
        type: 'email',
        required: false,
        colClass: 'col-md-6',
        placeholder: 'correo@ejemplo.com'
      },
      {
        key: 'fecha_expedicion',
        label: 'Fecha de Expedición',
        type: 'date',
        required: true,
        colClass: 'col-md-6'
      },
      {
        key: 'fecha_vencimiento',
        label: 'Fecha de Vencimiento',
        type: 'date',
        required: true,
        colClass: 'col-md-6'
      },
      {
        key: 'observaciones',
        label: 'Observaciones',
        type: 'textarea',
        required: false,
        colClass: 'col-md-12',
        placeholder: 'Observaciones adicionales'
      }
    ]
    
    return {
      displayFields,
      formFields
    }
  }
}
</script>

<style scoped>
.licencias-module {
  min-height: 100vh;
}
</style>