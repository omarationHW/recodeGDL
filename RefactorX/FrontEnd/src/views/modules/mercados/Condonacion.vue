<template>
  <div class="condonacion-page">
    <h1>Condonación de Adeudos</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Condonación</span>
    </nav>
    <section class="busqueda-local">
      <h2>Búsqueda de Local</h2>
      <form @submit.prevent="buscarLocal">
        <div class="form-row">
          <label>Oficina</label>
          <input v-model.number="form.oficina" type="number" required min="1" />
          <label>Mercado</label>
          <input v-model.number="form.num_mercado" type="number" required min="1" />
          <label>Categoria</label>
          <input v-model.number="form.categoria" type="number" required min="1" />
          <label>Sección</label>
          <input v-model="form.seccion" maxlength="2" required />
          <label>Local</label>
          <input v-model.number="form.local" type="number" required min="1" />
          <label>Letra</label>
          <input v-model="form.letra_local" maxlength="1" />
          <label>Bloque</label>
          <input v-model="form.bloque" maxlength="1" />
          <button type="submit">Buscar</button>
        </div>
      </form>
      <div v-if="local">
        <p><strong>Nombre:</strong> {{ local.nombre }}</p>
        <p><strong>Descripción:</strong> {{ local.descripcion_local }}</p>
        <p><strong>Superficie:</strong> {{ local.superficie }}</p>
        <p><strong>Clave Cuota:</strong> {{ local.clave_cuota }}</p>
      </div>
      <div v-if="error" class="error">{{ error }}</div>
    </section>

    <section v-if="local" class="adeudos-section">
      <h2>Adeudos a Condonar</h2>
      <button @click="listarAdeudos">Listar Adeudos</button>
      <table v-if="adeudos.length">
        <thead>
          <tr>
            <th></th>
            <th>Año</th>
            <th>Mes</th>
            <th>Importe</th>
            <th>Detalle</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(a, idx) in adeudos" :key="idx">
            <td><input type="checkbox" v-model="a.selected" /></td>
            <td>{{ a.expression_1 }}</td>
            <td>{{ a.expression_2 }}</td>
            <td>{{ a.expression_3 }}</td>
            <td>{{ a.expression_4 }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="adeudos.length">
        <label>Oficio:</label>
        <input v-model="oficio" maxlength="13" placeholder="LLL/9999/9999" />
        <button @click="condonarSeleccionados">Condonar Seleccionados</button>
      </div>
    </section>

    <section v-if="local" class="condonados-section">
      <h2>Condonados</h2>
      <button @click="listarCondonados">Listar Condonados</button>
      <table v-if="condonados.length">
        <thead>
          <tr>
            <th></th>
            <th>Año</th>
            <th>Mes</th>
            <th>Importe</th>
            <th>Observación</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(c, idx) in condonados" :key="idx">
            <td><input type="checkbox" v-model="c.selected" /></td>
            <td>{{ c.axo }}</td>
            <td>{{ c.periodo }}</td>
            <td>{{ c.importe }}</td>
            <td>{{ c.observacion }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="condonados.length">
        <button @click="deshacerCondonacion">Deshacer Condonación Seleccionada</button>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'CondonacionPage',
  data() {
    return {
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: ''
      },
      local: null,
      error: '',
      adeudos: [],
      condonados: [],
      oficio: ''
    };
  },
  methods: {
    async buscarLocal() {
      this.error = '';
      this.local = null;
      this.adeudos = [];
      this.condonados = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'buscar_local',
          data: { ...this.form }
        });
        if (res.data.status === 'success') {
          this.local = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async listarAdeudos() {
      if (!this.local) return;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'listar_adeudos',
          data: { id_local: this.local.id_local }
        });
        if (res.data.status === 'success') {
          this.adeudos = (res.data.data || []).map(a => ({ ...a, selected: false }));
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async condonarSeleccionados() {
      if (!this.oficio || this.oficio.trim().length < 10) {
        this.error = 'Debe ingresar el número de oficio válido';
        return;
      }
      const seleccionados = this.adeudos.filter(a => a.selected);
      if (!seleccionados.length) {
        this.error = 'Debe seleccionar al menos un adeudo';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'condonar_adeudos',
          data: {
            id_local: this.local.id_local,
            oficio: this.oficio,
            adeudos: seleccionados.map(a => ({
              axo: a.expression_1,
              periodo: a.expression_2,
              importe: a.expression_3
            }))
          }
        });
        if (res.data.status === 'success') {
          this.listarAdeudos();
          this.listarCondonados();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async listarCondonados() {
      if (!this.local) return;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'listar_condonados',
          data: { id_local: this.local.id_local }
        });
        if (res.data.status === 'success') {
          this.condonados = (res.data.data || []).map(c => ({ ...c, selected: false }));
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async deshacerCondonacion() {
      const seleccionados = this.condonados.filter(c => c.selected);
      if (!seleccionados.length) {
        this.error = 'Debe seleccionar al menos un condonado';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'deshacer_condonacion',
          data: {
            id_local: this.local.id_local,
            condonados: seleccionados.map(c => ({
              id_cancelacion: c.id_cancelacion,
              id_local: c.id_local,
              axo: c.axo,
              periodo: c.periodo,
              importe: c.importe,
              observacion: c.observacion
            }))
          }
        });
        if (res.data.status === 'success') {
          this.listarAdeudos();
          this.listarCondonados();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    }
  }
};
</script>

<style scoped>
.condonacion-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.busqueda-local, .adeudos-section, .condonados-section {
  margin-bottom: 2rem;
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}
.form-row label {
  min-width: 60px;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
table th, table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
</style>
