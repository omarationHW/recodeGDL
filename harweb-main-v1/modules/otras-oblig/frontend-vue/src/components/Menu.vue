<template>
  <div class="menu-page">
    <div class="header">
      <img :src="escudoUrl" alt="Escudo" class="escudo" />
      <div class="titles">
        <h1>H. Ayuntamiento Constitucional de Guadalajara</h1>
        <h2>Dirección de Ingresos</h2>
        <h3>Otras Obligaciones</h3>
      </div>
      <div class="user-info">
        <div>{{ fecha }}</div>
        <div>{{ user.nombre }}</div>
        <select v-model="ejercicio" @change="onEjercicioChange">
          <option v-for="e in ejercicios" :key="e.ejercicio" :value="e.ejercicio">{{ e.ejercicio }}</option>
        </select>
      </div>
    </div>
    <div class="menu-content">
      <div class="menu-sidebar">
        <ul>
          <li v-for="grupo in menu" :key="grupo.nombre">
            <strong>{{ grupo.nombre }}</strong>
            <ul>
              <li v-for="opcion in grupo.opciones" :key="opcion.id">
                <button :disabled="!opcion.enabled" @click="onMenuClick(opcion)">{{ opcion.titulo }}</button>
              </li>
            </ul>
          </li>
        </ul>
      </div>
      <div class="menu-main">
        <component :is="currentComponent" v-if="currentComponent" :user="user" :ejercicio="ejercicio" />
        <div v-else class="welcome">
          <h2>Bienvenido al Sistema de Menú General</h2>
          <p>Seleccione una opción del menú para comenzar.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
// Importar componentes de formularios individuales aquí si es necesario
// import FormularioAlta from './FormularioAlta.vue';
// ...

export default {
  name: 'MenuPage',
  components: {
    // FormularioAlta,
    // ...
  },
  data() {
    return {
      user: {},
      ejercicios: [],
      ejercicio: null,
      menu: [],
      fecha: '',
      escudoUrl: '/img/escudo.png',
      currentComponent: null
    };
  },
  created() {
    this.init();
  },
  methods: {
    async init() {
      // Simulación de login automático (en producción, usar login real)
      const usuario = localStorage.getItem('usuario') || 'demo';
      const password = localStorage.getItem('password') || 'demo';
      const loginResp = await axios.post('/api/execute', {
        eRequest: {
          operation: 'login',
          params: { usuario, password }
        }
      });
      if (loginResp.data.eResponse.status === 'ok') {
        this.user = loginResp.data.eResponse.user;
        await this.loadEjercicios();
        await this.loadMenu();
        this.fecha = this.formatFecha(new Date());
      } else {
        alert('Acceso denegado: ' + loginResp.data.eResponse.message);
        // Redirigir a login si es necesario
      }
    },
    async loadEjercicios() {
      const resp = await axios.post('/api/execute', {
        eRequest: { operation: 'getEjercicios' }
      });
      this.ejercicios = resp.data.eResponse.ejercicios;
      if (this.ejercicios.length > 0) {
        this.ejercicio = this.ejercicios[this.ejercicios.length - 1].ejercicio;
      }
    },
    async loadMenu() {
      const resp = await axios.post('/api/execute', {
        eRequest: {
          operation: 'getMenu',
          params: { usuario: this.user.usuario }
        }
      });
      this.menu = resp.data.eResponse.menu;
    },
    onEjercicioChange() {
      // Guardar ejercicio seleccionado si es necesario
    },
    onMenuClick(opcion) {
      // Aquí se puede usar router o cargar componente dinámico
      // this.$router.push({ name: opcion.route });
      // O cargar componente local:
      // this.currentComponent = opcion.componente;
      alert('Opción seleccionada: ' + opcion.titulo);
    },
    formatFecha(date) {
      // Formato: 1 de Enero de 2024
      const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
      return `${date.getDate()} de ${meses[date.getMonth()]} de ${date.getFullYear()}`;
    }
  }
};
</script>

<style scoped>
.menu-page {
  font-family: 'Segoe UI', Arial, sans-serif;
  background: #f8f8f8;
  min-height: 100vh;
}
.header {
  display: flex;
  align-items: center;
  background: #1e3a5c;
  color: #fff;
  padding: 1rem;
}
.escudo {
  width: 70px;
  height: 70px;
  margin-right: 1rem;
}
.titles h1 {
  margin: 0;
  font-size: 1.5rem;
}
.titles h2 {
  margin: 0;
  font-size: 1.2rem;
}
.titles h3 {
  margin: 0;
  font-size: 1rem;
}
.user-info {
  margin-left: auto;
  text-align: right;
}
.menu-content {
  display: flex;
  min-height: 80vh;
}
.menu-sidebar {
  width: 250px;
  background: #e3e3e3;
  padding: 1rem;
}
.menu-sidebar ul {
  list-style: none;
  padding: 0;
}
.menu-sidebar li {
  margin-bottom: 0.5rem;
}
.menu-sidebar button {
  width: 100%;
  padding: 0.5rem;
  background: #1e3a5c;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.menu-sidebar button:disabled {
  background: #aaa;
  cursor: not-allowed;
}
.menu-main {
  flex: 1;
  padding: 2rem;
  background: #fff;
}
.welcome {
  text-align: center;
  margin-top: 5rem;
}
</style>
