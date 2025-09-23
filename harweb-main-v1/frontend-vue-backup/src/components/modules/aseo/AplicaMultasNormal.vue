<template>
  <div class="aplica-multas-normal-page">
    <h2>Aplicación Normal de Requerimientos para Cobro</h2>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="form-row">
          <label>Descripción</label>
          <input type="text" v-model="form.descripcion" disabled />
        </div>
        <div class="form-row">
          <label>Aplica</label>
          <input type="text" v-model="form.aplica" disabled style="width:40px" />
        </div>
        <div class="form-row">
          <label>%</label>
          <input type="number" v-model.number="form.porc" disabled style="width:60px" />
        </div>
        <div class="form-row">
          <label>Aplicación de Requerimiento Normal</label>
          <div>
            <label><input type="radio" value="S" v-model="aplicaRadio" /> SI</label>
            <label><input type="radio" value="N" v-model="aplicaRadio" /> NO</label>
          </div>
        </div>
        <div class="form-row" v-if="aplicaRadio === 'N'">
          <label>Porcentaje</label>
          <input type="number" v-model.number="porcInput" min="0" max="100" />
        </div>
        <div class="form-actions">
          <button type="submit" :disabled="submitting">Guardar Cambios</button>
          <button type="button" @click="goBack">Salir</button>
        </div>
        <div v-if="message" class="message">{{ message }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AplicaMultasNormalPage',
  data() {
    return {
      loading: true,
      submitting: false,
      form: {
        descripcion: '',
        aplica: '',
        porc: 0
      },
      aplicaRadio: 'S',
      porcInput: 0,
      message: ''
    }
  },
  created() {
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_aplicareq' })
        });
        const data = await res.json();
        if (data.success && data.data) {
          this.form = { ...data.data };
          this.aplicaRadio = data.data.aplica;
          this.porcInput = data.data.porc;
        }
      } catch (e) {
        this.message = 'Error al cargar datos';
      }
      this.loading = false;
    },
    async onSubmit() {
      this.submitting = true;
      this.message = '';
      let porc = this.aplicaRadio === 'S' ? 0 : parseInt(this.porcInput) || 0;
      if (this.aplicaRadio === 'N' && porc <= 0) {
        this.message = 'Falta el porcentaje de Aplicación de Multa';
        this.submitting = false;
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'update_aplicareq',
            params: {
              aplica: this.aplicaRadio,
              porc: porc
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.message = data.message;
          await this.fetchData();
        } else {
          this.message = data.message || 'Error al guardar';
        }
      } catch (e) {
        this.message = 'Error de red o servidor';
      }
      this.submitting = false;
    },
    goBack() {
      this.$router ? this.$router.back() : window.history.back();
    }
  }
}
</script>

<style scoped>
.aplica-multas-normal-page {
  max-width: 600px;
  margin: 40px auto;
  background: #fff;
  border-radius: 8px;
  padding: 32px 24px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  margin-bottom: 18px;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input[type="text"],
.form-row input[type="number"] {
  flex: 1;
  padding: 6px 8px;
  font-size: 1em;
}
.form-actions {
  margin-top: 24px;
  display: flex;
  gap: 16px;
}
.message {
  margin-top: 18px;
  color: #1976d2;
  font-weight: bold;
}
.loading {
  text-align: center;
  font-size: 1.2em;
  color: #888;
}
</style>
