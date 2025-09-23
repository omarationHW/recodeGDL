<template>
  <div class="abstenmov-page">
    <h1>Abstención de Movimientos</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <section class="predio-info">
        <h2>Datos del Predio</h2>
        <div class="predio-fields">
          <div><strong>Propietario:</strong> {{ propietario?.nombre_completo || '-' }}</div>
          <div><strong>Ubicación:</strong> {{ ubicacion?.calle || '-' }} {{ ubicacion?.noexterior || '' }} {{ ubicacion?.interior || '' }}</div>
          <div><strong>Observ. Ubicación:</strong> {{ ubicacion?.obsinter || '-' }}</div>
        </div>
      </section>
      <section class="efectos-form">
        <h2>Efectos</h2>
        <form @submit.prevent="onSubmit">
          <div class="form-row">
            <label for="axoefec">Año</label>
            <input id="axoefec" v-model.number="form.axoefec" type="number" min="1900" max="2100" required :disabled="isAbstencionActiva" />
          </div>
          <div class="form-row">
            <label for="bimefec">Bimestre</label>
            <select id="bimefec" v-model.number="form.bimefec" required :disabled="isAbstencionActiva">
              <option v-for="b in [1,2,3,4,5,6]" :key="b" :value="b">{{ b }}</option>
            </select>
          </div>
          <div class="form-row">
            <label for="observacion">Observaciones al movimiento</label>
            <textarea id="observacion" v-model="form.observacion" required :disabled="isAbstencionActiva"></textarea>
          </div>
          <div class="form-actions">
            <button type="submit" :disabled="isAbstencionActiva || submitting">Registrar Abstención</button>
            <button type="button" @click="onEliminar" :disabled="!isAbstencionActiva || submitting">Eliminar Abstención</button>
          </div>
        </form>
        <div v-if="message" :class="{'success': success, 'error': !success}">{{ message }}</div>
      </section>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AbstenMovPage',
  data() {
    return {
      loading: true,
      submitting: false,
      cvecuenta: null,
      predio: null,
      ubicacion: null,
      propietario: null,
      form: {
        axoefec: '',
        bimefec: '',
        observacion: ''
      },
      isAbstencionActiva: false,
      message: '',
      success: false
    };
  },
  created() {
    // Suponiendo que la ruta es /abstenmov/:cvecuenta
    this.cvecuenta = this.$route.params.cvecuenta;
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'get_predio_data',
          payload: { cvecuenta: this.cvecuenta }
        });
        if (res.data.success) {
          this.predio = res.data.data.predio;
          this.ubicacion = res.data.data.ubicacion;
          this.propietario = res.data.data.propietario;
          this.form.axoefec = this.predio.axoefec;
          this.form.bimefec = this.predio.bimefec;
          this.isAbstencionActiva = this.predio.cvemov === 12;
        } else {
          this.message = res.data.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.message = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.message = '';
      this.success = false;
      this.submitting = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'registrar_abstencion',
          payload: {
            cvecuenta: this.cvecuenta,
            axoefec: this.form.axoefec,
            bimefec: this.form.bimefec,
            observacion: this.form.observacion,
            usuario: this.$store.state.auth.user.username // o como corresponda
          }
        });
        if (res.data.success) {
          this.message = res.data.data.message;
          this.success = true;
          this.isAbstencionActiva = true;
        } else {
          this.message = res.data.message || 'Error al registrar abstención';
        }
      } catch (e) {
        this.message = e.message || 'Error de red';
      } finally {
        this.submitting = false;
      }
    },
    async onEliminar() {
      if (!confirm('¿Está seguro de eliminar la abstención?')) return;
      this.message = '';
      this.success = false;
      this.submitting = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'eliminar_abstencion',
          payload: {
            cvecuenta: this.cvecuenta,
            axoefec: this.form.axoefec,
            bimefec: this.form.bimefec,
            observacion: this.form.observacion,
            usuario: this.$store.state.auth.user.username
          }
        });
        if (res.data.success) {
          this.message = res.data.data.message;
          this.success = true;
          this.isAbstencionActiva = false;
        } else {
          this.message = res.data.message || 'Error al eliminar abstención';
        }
      } catch (e) {
        this.message = e.message || 'Error de red';
      } finally {
        this.submitting = false;
      }
    }
  }
};
</script>

<style scoped>
.abstenmov-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.predio-info {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 2rem;
  border-radius: 6px;
}
.efectos-form {
  background: #f4f9ff;
  padding: 1.5rem;
  border-radius: 6px;
}
.form-row {
  margin-bottom: 1rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
}
.success {
  color: green;
  margin-top: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.loading {
  font-size: 1.2em;
  color: #888;
}
</style>
