<template>
  <div v-if="show" class="modal" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Alta de Contrato</h2>
      </div>
      
      <form @submit.prevent="submitForm">
        <div class="form-group">
          <label>Número de Contrato:</label>
          <input 
            v-model.number="form.contrato" 
            type="number" 
            required
            placeholder="Ingrese el número de contrato"
          >
        </div>
        
        <div class="form-group">
          <label>Nombre:</label>
          <input 
            v-model="form.nombre" 
            type="text" 
            required
            maxlength="100"
            placeholder="Nombre del beneficiario"
          >
        </div>
        
        <div class="form-group">
          <label>Calle:</label>
          <input 
            v-model="form.calle" 
            type="text" 
            required
            maxlength="100"
            placeholder="Dirección de la obra"
          >
        </div>
        
        <div class="form-group">
          <label>Metros:</label>
          <input 
            v-model.number="form.metros" 
            type="number" 
            step="0.01"
            min="0.01"
            max="999.99"
            required
            placeholder="Metros cuadrados"
          >
        </div>
        
        <div class="form-group">
          <label>Costo por Metro:</label>
          <input 
            v-model.number="form.costomtr" 
            type="number" 
            step="0.01"
            min="0.01"
            required
            placeholder="Costo por metro cuadrado"
          >
        </div>
        
        <div class="form-group">
          <label>Tipo de Pavimento:</label>
          <div class="radio-group">
            <label>
              <input 
                v-model="form.tipo_pavimento" 
                type="radio" 
                value="A"
                required
              >
              ASFALTO
            </label>
            <label>
              <input 
                v-model="form.tipo_pavimento" 
                type="radio" 
                value="H"
                required
              >
              CONCRETO HIDRÁULICO
            </label>
          </div>
        </div>
        
        <div class="modal-footer">
          <button type="button" @click="$emit('close')" class="btn-danger">
            Cancelar
          </button>
          <button type="submit" class="btn-primary">
            Alta registro
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProyectoModal',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'submit'],
  data() {
    return {
      form: {
        contrato: null,
        nombre: '',
        calle: '',
        metros: null,
        costomtr: null,
        tipo_pavimento: 'A'
      }
    }
  },
  watch: {
    show(newVal) {
      if (!newVal) {
        this.resetForm();
      }
    }
  },
  methods: {
    submitForm() {
      this.$emit('submit', { ...this.form });
    },
    resetForm() {
      this.form = {
        contrato: null,
        nombre: '',
        calle: '',
        metros: null,
        costomtr: null,
        tipo_pavimento: 'A'
      };
    }
  }
}
</script>