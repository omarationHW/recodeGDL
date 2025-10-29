<template>
  <div class="tipobloqueo-form-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Bloqueo de Licencia</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header text-center font-weight-bold">
        BLOQUEO DE LICENCIA
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group">
            <label for="tipoBloqueo">TIPO DE BLOQUEO</label>
            <select v-model="form.tipo_bloqueo_id" id="tipoBloqueo" class="form-control" required>
              <option value="" disabled>Seleccione un tipo de bloqueo</option>
              <option v-for="tipo in tiposBloqueo" :key="tipo.id" :value="tipo.id">
                {{ tipo.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label for="motivo">Motivo:</label>
            <input
              id="motivo"
              v-model="form.motivo"
              type="text"
              class="form-control"
              maxlength="255"
              style="text-transform:uppercase"
              required
            />
          </div>
          <div class="form-group d-flex justify-content-end">
            <button type="button" class="btn btn-secondary mr-2" @click="onCancel">Cancelar</button>
            <button type="submit" class="btn btn-primary">Aceptar</button>
          </div>
        </form>
        <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}" class="mt-3">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TipoBloqueoForm',
  data() {
    return {
      tiposBloqueo: [],
      form: {
        tipo_bloqueo_id: '',
        motivo: '',
        usuario_id: 1, // Simulado, reemplazar con auth real
        licencia_id: null // Debe ser pasado como prop o por ruta
      },
      message: '',
      success: false
    };
  },
  props: {
    licenciaId: {
      type: [String, Number],
      required: true
    }
  },
  mounted() {
    this.form.licencia_id = this.licenciaId;
    this.fetchTiposBloqueo();
  },
  methods: {
    async fetchTiposBloqueo() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.get_tipo_bloqueo_catalog',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.tiposBloqueo = res.data.data;
        } else {
          this.message = res.data.message || 'Error al cargar tipos de bloqueo';
          this.success = false;
        }
      } catch (error) {
        this.message = 'Error de conexión al cargar tipos de bloqueo';
        this.success = false;
      }
    },
    async onSubmit() {
      this.message = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.bloquear_licencia',
          payload: {
            tipo_bloqueo_id: this.form.tipo_bloqueo_id,
            motivo: this.form.motivo.toUpperCase(),
            usuario_id: this.form.usuario_id,
            licencia_id: this.form.licencia_id
          }
        });
        if (res.data.status === 'success') {
          this.message = res.data.message || 'Bloqueo realizado correctamente';
          this.success = true;
          this.$emit('bloqueo-success', {
            tipo_bloqueo_id: this.form.tipo_bloqueo_id,
            motivo: this.form.motivo.toUpperCase()
          });
        } else {
          this.message = res.data.message || 'Error al bloquear licencia';
          this.success = false;
        }
      } catch (error) {
        this.message = 'Error de conexión al bloquear licencia';
        this.success = false;
      }
    },
    onCancel() {
      this.$router.back();
    }
  }
};
</script>

<style scoped>
.tipobloqueo-form-page {
  max-width: 500px;
  margin: 40px auto;
}
.card-header {
  font-size: 1.2rem;
}
</style>
