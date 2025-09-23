<template>
  <div class="modif-masiva-page">
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Apremios</span> &gt; <span>Modificación Masiva</span>
    </nav>
    <h1>Modificación Masiva de Apremios</h1>
    
    <div class="wizard-steps">
      <div :class="['step', { active: currentStep === 1 }]">1. Selección</div>
      <div :class="['step', { active: currentStep === 2 }]">2. Filtros</div>
      <div :class="['step', { active: currentStep === 3 }]">3. Cambios</div>
      <div :class="['step', { active: currentStep === 4 }]">4. Confirmación</div>
    </div>

    <!-- Step 1: Selección de módulo -->
    <div v-if="currentStep === 1" class="step-content">
      <h2>Paso 1: Seleccionar Aplicación</h2>
      <form @submit.prevent="nextStep">
        <div class="form-row">
          <label>Aplicación:</label>
          <select v-model="form.modulo" required>
            <option :value="11">11 Mercados</option>
            <option :value="16">16 Aseo</option>
            <option :value="24">24 Estacionamientos Públicos</option>
            <option :value="28">28 Estacionamientos Exclusivos</option>
            <option :value="14">14 Estacionómetros</option>
            <option :value="13">13 Cementerios</option>
          </select>
        </div>
        <div class="form-row">
          <label>Recaudadora:</label>
          <select v-model="form.recaudadora" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.recaudadora }}
            </option>
          </select>
        </div>
        <div class="form-actions">
          <button type="submit">Siguiente</button>
        </div>
      </form>
    </div>

    <!-- Step 2: Filtros -->
    <div v-if="currentStep === 2" class="step-content">
      <h2>Paso 2: Definir Filtros</h2>
      <form @submit.prevent="nextStep">
        <div class="form-row">
          <label>Rango de Folios:</label>
          <input type="number" v-model.number="form.folioDesde" placeholder="Desde" />
          <input type="number" v-model.number="form.folioHasta" placeholder="Hasta" />
        </div>
        <div class="form-row">
          <label>Fecha Emisión:</label>
          <input type="date" v-model="form.fechaDesde" />
          <input type="date" v-model="form.fechaHasta" />
        </div>
        <div class="form-row">
          <label>Ejecutor:</label>
          <select v-model="form.ejecutor">
            <option value="">Todos</option>
            <option v-for="ej in ejecutores" :key="ej.cve_eje" :value="ej.cve_eje">
              {{ ej.cve_eje }} - {{ ej.nombre }}
            </option>
          </select>
        </div>
        <div class="form-actions">
          <button type="button" @click="prevStep">Anterior</button>
          <button type="submit">Siguiente</button>
        </div>
      </form>
    </div>

    <!-- Step 3: Cambios a aplicar -->
    <div v-if="currentStep === 3" class="step-content">
      <h2>Paso 3: Definir Cambios</h2>
      <form @submit.prevent="nextStep">
        <div class="form-row">
          <label>Nuevo Ejecutor:</label>
          <select v-model="form.nuevoEjecutor">
            <option value="">Sin cambio</option>
            <option v-for="ej in ejecutores" :key="ej.cve_eje" :value="ej.cve_eje">
              {{ ej.cve_eje }} - {{ ej.nombre }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Nueva Zona Apremio:</label>
          <input type="number" v-model.number="form.nuevaZona" placeholder="Sin cambio" />
        </div>
        <div class="form-row">
          <label>Agregar Observaciones:</label>
          <textarea v-model="form.nuevasObservaciones" maxlength="255"></textarea>
        </div>
        <div class="form-actions">
          <button type="button" @click="prevStep">Anterior</button>
          <button type="submit">Vista Previa</button>
        </div>
      </form>
    </div>

    <!-- Step 4: Confirmación -->
    <div v-if="currentStep === 4" class="step-content">
      <h2>Paso 4: Confirmación</h2>
      <div class="preview-info">
        <h3>Resumen de Cambios</h3>
        <p><strong>Aplicación:</strong> {{ form.modulo }}</p>
        <p><strong>Recaudadora:</strong> {{ form.recaudadora }}</p>
        <p><strong>Folios:</strong> {{ form.folioDesde }} - {{ form.folioHasta }}</p>
        <p><strong>Registros afectados:</strong> {{ registrosAfectados }}</p>
      </div>
      <div class="form-actions">
        <button type="button" @click="prevStep" class="btn-secondary">Anterior</button>
        <button type="button" @click="aplicarCambios" class="btn-danger">Aplicar Cambios</button>
      </div>
    </div>

    <div v-if="errors.length" class="error-list">
      <ul>
        <li v-for="err in errors" :key="err">{{ err }}</li>
      </ul>
    </div>
    <div v-if="successMessage" class="success-message">
      {{ successMessage }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModifMasiva',
  data() {
    return {
      currentStep: 1,
      form: {
        modulo: 11,
        recaudadora: '',
        folioDesde: '',
        folioHasta: '',
        fechaDesde: '',
        fechaHasta: '',
        ejecutor: '',
        nuevoEjecutor: '',
        nuevaZona: '',
        nuevasObservaciones: ''
      },
      recaudadoras: [],
      ejecutores: [],
      registrosAfectados: 0,
      errors: [],
      successMessage: ''
    }
  },
  created() {
    this.cargarRecaudadoras();
  },
  watch: {
    'form.recaudadora'(val) {
      if (val) this.cargarEjecutores(val);
    }
  },
  methods: {
    async cargarRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getRecaudadoras'
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.recaudadoras = data.data;
        }
      } catch (e) {
        this.errors = ['Error al cargar recaudadoras: ' + e.message];
      }
    },
    async cargarEjecutores(recaudadora) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getEjecutores',
          params: { recaudadora }
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.ejecutores = data.data;
        }
      } catch (e) {
        this.errors = ['Error al cargar ejecutores: ' + e.message];
      }
    },
    nextStep() {
      if (this.currentStep < 4) {
        this.currentStep++;
        if (this.currentStep === 4) {
          this.calcularAfectados();
        }
      }
    },
    prevStep() {
      if (this.currentStep > 1) {
        this.currentStep--;
      }
    },
    async calcularAfectados() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'contarRegistrosModificar',
          params: this.form
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.registrosAfectados = data.data.count;
        }
      } catch (e) {
        this.registrosAfectados = 0;
      }
    },
    async aplicarCambios() {
      this.errors = [];
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'modificacionMasiva',
          params: this.form
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.successMessage = `Se han modificado ${data.data.affected} registros correctamente`;
          this.currentStep = 1;
          this.resetForm();
        } else {
          this.errors = data.errors.length ? data.errors : ['Error en la modificación masiva'];
        }
      } catch (e) {
        this.errors = [e.message];
      }
    },
    resetForm() {
      this.form = {
        modulo: 11,
        recaudadora: '',
        folioDesde: '',
        folioHasta: '',
        fechaDesde: '',
        fechaHasta: '',
        ejecutor: '',
        nuevoEjecutor: '',
        nuevaZona: '',
        nuevasObservaciones: ''
      };
      this.registrosAfectados = 0;
    }
  }
}
</script>

<style scoped>
.modif-masiva-page {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1em;
}
.wizard-steps {
  display: flex;
  justify-content: space-between;
  margin: 2em 0;
  padding: 0;
}
.step {
  flex: 1;
  text-align: center;
  padding: 1em;
  background: #f0f0f0;
  margin: 0 0.2em;
  border-radius: 4px;
}
.step.active {
  background: #007bff;
  color: white;
}
.step-content {
  background: #f9f9f9;
  padding: 2em;
  border-radius: 6px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
  margin-bottom: 1em;
  align-items: center;
}
.form-row label {
  min-width: 150px;
  font-weight: bold;
}
.form-actions {
  text-align: right;
  margin-top: 2em;
}
.form-actions button {
  margin-left: 0.5em;
}
.btn-secondary {
  background: #6c757d;
  color: white;
}
.btn-danger {
  background: #dc3545;
  color: white;
}
.preview-info {
  background: white;
  padding: 1em;
  border-radius: 4px;
  margin-bottom: 1em;
}
.error-list {
  color: #b00;
  margin-top: 1em;
}
.success-message {
  color: #080;
  margin-top: 1em;
  font-weight: bold;
}
</style>