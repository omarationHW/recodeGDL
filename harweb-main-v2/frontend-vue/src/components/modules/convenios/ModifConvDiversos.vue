<template>
  <div class="modif-conv-diversos-page">
    <h1>Modificación de Convenios Diversos</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label>Tipo:</label>
        <select v-model="form.tipo" @change="onTipoChange">
          <option v-for="tipo in tipos" :key="tipo.tipo" :value="tipo.tipo">{{ tipo.tipo }} - {{ tipo.descripcion }}</option>
        </select>
        <label>Subtipo:</label>
        <select v-model="form.subtipo">
          <option v-for="sub in subtipos" :key="sub.subtipo" :value="sub.subtipo">{{ sub.subtipo }} - {{ sub.desc_subtipo }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Letras Oficio:</label>
        <input v-model="form.letras_ofi" maxlength="4" />
        <label>Folio Oficio:</label>
        <input v-model="form.folio_ofi" type="number" />
        <label>Año Oficio:</label>
        <input v-model="form.alo_oficio" type="number" />
      </div>
      <div class="form-row">
        <button type="submit">Buscar Convenio</button>
      </div>
    </form>

    <div v-if="convenio">
      <h2>Datos Generales</h2>
      <form @submit.prevent="onModificarDatosGenerales">
        <div class="form-row">
          <label>Nombre:</label>
          <input v-model="convenio.nombre" maxlength="50" />
          <label>Calle:</label>
          <input v-model="convenio.calle" maxlength="50" />
        </div>
        <div class="form-row">
          <label>Exterior:</label>
          <input v-model="convenio.num_exterior" type="number" />
          <label>Interior:</label>
          <input v-model="convenio.num_interior" type="number" />
          <label>Inciso:</label>
          <input v-model="convenio.inciso" maxlength="10" />
        </div>
        <div class="form-row">
          <label>Metros:</label>
          <input v-model="convenio.metros" type="number" step="0.01" />
          <label>Teléfono:</label>
          <input v-model="convenio.telefono" maxlength="20" />
          <label>Correo:</label>
          <input v-model="convenio.correo" maxlength="40" />
        </div>
        <div class="form-row">
          <label>Oficio:</label>
          <input v-model="convenio.oficio" maxlength="30" />
          <label>Fecha Oficio:</label>
          <input v-model="convenio.fechaoficio" type="date" />
          <label>Nombre Firma:</label>
          <input v-model="convenio.nombrefirma" maxlength="60" />
        </div>
        <div class="form-row">
          <label>Observaciones:</label>
          <textarea v-model="convenio.observaciones" maxlength="60"></textarea>
        </div>
        <div class="form-row">
          <button type="submit">Modificar Datos Generales</button>
        </div>
      </form>
      <div class="form-row">
        <button @click="onBloquearConvenio">Bloquear Convenio</button>
        <button @click="onDesbloquearConvenio">Desbloquear Convenio</button>
        <button @click="onDarPagadoConvenio">Dar como Pagado</button>
        <button @click="onDarBajaConvenio">Dar de Baja</button>
      </div>
      <div v-if="message" class="message">{{ message }}</div>
    </div>
    <div v-else-if="message" class="message">{{ message }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ModifConvDiversosPage',
  data() {
    return {
      tipos: [],
      subtipos: [],
      form: {
        tipo: '',
        subtipo: '',
        letras_ofi: '',
        folio_ofi: '',
        alo_oficio: ''
      },
      convenio: null,
      message: ''
    };
  },
  created() {
    this.fetchTipos();
  },
  methods: {
    async fetchTipos() {
      const res = await axios.post('/api/execute', { action: 'listarTipos' });
      this.tipos = res.data.data;
    },
    async onTipoChange() {
      this.form.subtipo = '';
      this.subtipos = [];
      if (this.form.tipo) {
        const res = await axios.post('/api/execute', { action: 'listarSubtipos', params: { tipo: this.form.tipo } });
        this.subtipos = res.data.data;
      }
    },
    async onBuscar() {
      this.message = '';
      this.convenio = null;
      try {
        const res = await axios.post('/api/execute', {
          action: 'buscarConvenio',
          params: {
            tipo: this.form.tipo,
            subtipo: this.form.subtipo,
            letras_ofi: this.form.letras_ofi,
            folio_ofi: this.form.folio_ofi,
            alo_oficio: this.form.alo_oficio
          }
        });
        if (res.data.data && res.data.data.length > 0) {
          this.convenio = res.data.data[0];
        } else {
          this.message = 'No existe el convenio digitado';
        }
      } catch (e) {
        this.message = e.response?.data?.message || 'Error en la búsqueda';
      }
    },
    async onModificarDatosGenerales() {
      try {
        const res = await axios.post('/api/execute', {
          action: 'modificarDatosGenerales',
          params: {
            ...this.convenio
          }
        });
        this.message = res.data.message;
      } catch (e) {
        this.message = e.response?.data?.message || 'Error al modificar';
      }
    },
    async onBloquearConvenio() {
      try {
        const res = await axios.post('/api/execute', {
          action: 'bloquearConvenio',
          params: {
            id_conv_resto: this.convenio.id_conv_resto,
            observaciones: this.convenio.observaciones
          }
        });
        this.message = res.data.message;
      } catch (e) {
        this.message = e.response?.data?.message || 'Error al bloquear';
      }
    },
    async onDesbloquearConvenio() {
      try {
        const res = await axios.post('/api/execute', {
          action: 'desbloquearConvenio',
          params: {
            id_conv_resto: this.convenio.id_conv_resto,
            observaciones: this.convenio.observaciones
          }
        });
        this.message = res.data.message;
      } catch (e) {
        this.message = e.response?.data?.message || 'Error al desbloquear';
      }
    },
    async onDarPagadoConvenio() {
      try {
        const res = await axios.post('/api/execute', {
          action: 'darPagadoConvenio',
          params: {
            id_conv_resto: this.convenio.id_conv_resto,
            modulo: this.convenio.modulo
          }
        });
        this.message = res.data.message;
      } catch (e) {
        this.message = e.response?.data?.message || 'Error al marcar como pagado';
      }
    },
    async onDarBajaConvenio() {
      try {
        const res = await axios.post('/api/execute', {
          action: 'darBajaConvenio',
          params: {
            id_conv_resto: this.convenio.id_conv_resto,
            modulo: this.convenio.modulo
          }
        });
        this.message = res.data.message;
      } catch (e) {
        this.message = e.response?.data?.message || 'Error al dar de baja';
      }
    }
  }
};
</script>

<style scoped>
.modif-conv-diversos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  align-items: center;
}
label {
  min-width: 100px;
  font-weight: bold;
}
input, select, textarea {
  flex: 1;
  padding: 0.3rem;
}
button {
  padding: 0.5rem 1.5rem;
  margin-right: 1rem;
}
.message {
  margin-top: 1rem;
  color: #b00;
  font-weight: bold;
}
</style>
